module Helpers
  module Mesos
    unless (const_defined?(:MESOS_INFO))
      MESOS_INFO = {
        'platforms' => ['ubuntu']
      }
    end

    def platform_supported?
      MESOS_INFO['platforms'].include?(node['platform'])
    end

    def mesos_version
      node[:mesos][:version]
    end

    def platform
      node['platform']
    end

    def platform_version
      node['platform_version']
    end

    def service_provider
      case platform
      when 'ubuntu'
        Chef::Provider::Service::Upstart
      end
    end
  end




  module Mesosphere extend Helpers::Mesos
    Chef::Resource::Package.send(:include, Helpers::Mesos)
    Chef::Resource::RemoteFile.send(:include, Helpers::Mesos)
    Chef::Resource::Service.send(:include, Helpers::Mesos)
    Chef::Resource::DpkgPackage.send(:include, Helpers::Mesos)
    Chef::Resource::Template.send(:include, Helpers::Mesos)
    Chef::Resource::Package.send(:include, Helpers::Mesosphere)
    Chef::Resource::RemoteFile.send(:include, Helpers::Mesosphere)
    Chef::Resource::Service.send(:include, Helpers::Mesosphere)
    Chef::Resource::DpkgPackage.send(:include, Helpers::Mesosphere)
    Chef::Resource::Template.send(:include, Helpers::Mesosphere)

    unless (const_defined?(:MESOSPHERE_INFO))
      MESOSPHERE_INFO = {
        'prefix' => {
          'ubuntu' => '/usr/local/sbin'
        },
        'zookeeper_packages' => {
          'ubuntu' => ['zookeeper', 'zookeeperd', 'zookeeper-bin']
        },
        'dependency_packages' => {
          'ubuntu' => ['unzip', 'libcurl3', 'default-jre-headless']
        }
      }
    end

    def prefix
      '/usr/local'
    end

    def installed?
      cmd = "#{MESOSPHERE_INFO['prefix'][platform]}/mesos-master --version |cut -f 2 -d ' '"
      File.exist?("#{MESOSPHERE_INFO['prefix'][platform]}/mesos-master") && (`#{cmd}`.chop == mesos_version)
    end

    def download_url
      mesosphere_io_prefix = "http://downloads.mesosphere.io/master/#{platform}/#{platform_version}"
      if mesos_version < "0.19.0" then
        "#{mesosphere_io_prefix}/mesos_#{mesos_version}_amd64.deb"
      elsif mesos_version == "0.19.0" then
        "#{mesosphere_io_prefix}/mesos_#{mesos_version}~#{platform}#{platform_version}%2B1_amd64.deb"
      else
        "#{mesosphere_io_prefix}/mesos_#{mesos_version}-1.0.#{platform}#{platform_version.sub('.','')}_amd64.deb"
      end
    end

    def include_mesos_recipe
      include_recipe "mesos::mesosphere"
    end

    def install_dependencies
      MESOSPHERE_INFO['dependency_packages'][platform].each do |pkg|
        package pkg do
          action :install
          not_if { (installed?) == true }
        end
      end
    end

    def install_zookeeper
      MESOSPHERE_INFO['zookeeper_packages'][platform].each do |zk|
        package zk do
          action :install
        end
      end
      case platform
      when 'ubuntu'
          service "zookeeper" do
            provider Chef::Provider::Service::Upstart
            action :restart
          end
      end
    end

    def install_mesos
      case platform
      when 'ubuntu'
        remote_file "#{Chef::Config[:file_cache_path]}/mesos_#{mesos_version}.deb" do
          source download_url
          mode   0644
          not_if { (installed?) == true }
          notifies :install, "dpkg_package[mesos]"
        end

        dpkg_package "mesos" do
          source "#{Chef::Config[:file_cache_path]}/mesos_#{mesos_version}.deb"
          action :install
          not_if { (installed?) == true }
        end
      end
    end

    def deploy_service_scripts
      case platform
      when 'ubuntu'
        # configuration files for upstart scripts by build_from_source installation
        template "/etc/init/mesos-master.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "stop", :role => "master")
          mode 0644
          owner "root"
          group "root"
          not_if { (installed?) == true }
          notifies :reload, "service[mesos-master]", :delayed
        end

        template "/etc/init/mesos-slave.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "stop", :role => "slave")
          mode 0644
          owner "root"
          group "root"
          not_if { (installed?) == true }
          notifies :reload, "service[mesos-slave]", :delayed
        end
      end
    end

    def activate_master_service_scripts
      case platform
      when 'ubuntu'
        template "/etc/init/mesos-master.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "start", :role => "master")
          mode 0644
          owner "root"
          group "root"
        end
      end
    end

    def activate_slave_service_scripts
      case platform
      when 'ubuntu'
        template "/etc/init/mesos-slave.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "start", :role => "slave")
          mode 0644
          owner "root"
          group "root"
        end
      end
    end
  end #of Module Mesosphere




  module Source extend Helpers::Mesos
    unless (const_defined?(:SOURCE_INFO))
      SOURCE_INFO = {
        'dependency_packages' => {
          # The list is necessary and sufficient?
          'ubuntu' => ["unzip", "libtool", "libltdl-dev", "autoconf", "automake", "libcurl3", "libcurl3-gnutls", "libcurl4-openssl-dev", "python-dev", "libsasl2-dev"]
        },
        'dependency_recipes' => {
          'ubuntu' => ["java", "python", "build-essential", "maven"]
        }
      }
    end

    def prefix
      node[:mesos][:prefix]
    end

    def installed?
      cmd = "#{prefix}/mesos-master --version |cut -f 2 -d ' '"
      File.exist?("#{prefix}/mesos-master") && (`#{cmd}`.chop == mesos_version)
    end

    def download_url
      "https://github.com/apache/mesos/archive/#{mesos_version}.zip"
    end

    def include_mesos_recipe
      include_recipe "mesos::build_from_source"
    end

    def include_dependency_recipes
      SOURCE_INFO['dependency_recipes'][platform].each do |r|
        include_recipe r
      end
    end

    def install_dependency_packages
      SOURCE_INFO['dependency_packages'][platform].each do |p|
        package p do
          action :install
        end
      end
    end

    def activate_master_service_scripts
      case platform
      when 'ubuntu'
        template "/etc/init/mesos-master.conf" do
          source "upstart.conf.for.buld_from_source.erb"
          variables(:init_state => "start", :role => "master")
          mode 0644
          owner "root"
          group "root"
        end
      end
    end

    def activate_slave_service_scripts
      case platform
      when 'ubuntu'
        template "/etc/init/mesos-slave.conf" do
          source "upstart.conf.for.buld_from_source.erb"
          variables(:init_state => "start", :role => "slave")
          mode 0644
          owner "root"
          group "root"
        end
      end
    end
  end #of Module Source
end #of Module Helpers
