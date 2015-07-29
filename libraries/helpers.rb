module Helpers
  module Mesos
    unless (const_defined?(:MESOS_INFO))
      MESOS_INFO = {
        'platforms' => ['ubuntu', 'centos']
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
      when 'ubuntu', 'centos'
        Chef::Provider::Service::Upstart
      end
    end
  end




  module Mesosphere extend Helpers::Mesos
    Chef::Resource::Bash.send(:include, ::Helpers::Mesos)
    Chef::Resource::Bash.send(:include, ::Helpers::Mesosphere)
    Chef::Resource::Package.send(:include, ::Helpers::Mesos)
    Chef::Resource::Package.send(:include, ::Helpers::Mesosphere)
    Chef::Resource::Service.send(:include, ::Helpers::Mesos)
    Chef::Resource::Service.send(:include, ::Helpers::Mesosphere)
    Chef::Resource::Template.send(:include, ::Helpers::Mesos)
    Chef::Resource::Template.send(:include, ::Helpers::Mesosphere)

    unless (const_defined?(:MESOSPHERE_INFO))
      MESOSPHERE_INFO = {
        'prefix' => {
          'ubuntu' => '/usr/local/sbin',
          'centos' => '/usr/local/sbin'
        },
        'zookeeper_packages' => {
          'ubuntu' => ['zookeeper', 'zookeeperd', 'zookeeper-bin'],
          'centos' => ['java-1.7.0-openjdk', 'zookeeper', 'zookeeper-server']
        }
      }
    end

    def prefix
      '/usr/local'
    end

    def build_version
      if node[:mesos][:mesosphere][:build_version]
        return node[:mesos][:mesosphere][:build_version]
      else
        case platform
        when 'ubuntu'
          return "-1.0.#{platform}#{platform_version.sub('.','')}"
        when 'centos'
          return "-1.0.#{platform}#{platform_version.sub('.','')}".sub('65','64')
        end
      end
    end

    def installed?
      cmd = "#{MESOSPHERE_INFO['prefix'][platform]}/mesos-master --version |cut -f 2 -d ' '"
      File.exist?("#{MESOSPHERE_INFO['prefix'][platform]}/mesos-master") && (`#{cmd}`.chop == mesos_version)
    end

    def include_mesos_recipe
      include_recipe "mesos::mesosphere"
    end

    def install_zookeeper
      # some preparation, if required.
      case platform
      when 'centos'
        bash "add CDH repository to gain access to Zookeeper packages." do
          code <<-EOH
            rpm -Uvh http://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm
            yum install -y -q curl
            curl -sSfL http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera --output /tmp/cdh.key
            rpm --import /tmp/cdh.key
          EOH
          action :run
        end
      end

      # package installation
      MESOSPHERE_INFO['zookeeper_packages'][platform].each do |zk|
        package zk do
          action :install
        end
      end

      # service restart
      case platform
      when 'ubuntu'
          service "zookeeper" do
            provider Chef::Provider::Service::Upstart
            action :restart
          end
      when 'centos'
          bash "zookeeper-sever init, if it's the first time." do
            code <<-EOH
              service zookeeper-server init || true
            EOH
            action :run
          end
          service "zookeeper-server" do
            provider Chef::Provider::Service::Init::Redhat
            action :restart
          end
      end
    end

    def install_mesos
      case platform
      when 'ubuntu'
        bash "add an apt's trusted key for mesosphere" do
          code <<-EOH
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
          EOH
          action :run
        end

        bash "add mesosphere repository" do
          code <<-EOH
            DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
            CODENAME=$(lsb_release -cs)
            echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
            sudo apt-get -y update
          EOH
          action :run
        end

        package "mesos" do
          action :install
          version "#{mesos_version}#{build_version}"
        end
      when 'centos'
        repo_url = value_for_platform(
          'centos' => {
            'default' => 'http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm',
            '7.0.1406' => 'http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm'
          },
        )

        bash "add mesosphere repository" do
          code <<-EOH
            rpm -Uvh #{repo_url} || true
          EOH
          action :run
        end
        package "mesos" do
          action :install
          version "#{mesos_version}#{build_version}"
        end
      end
    end

    def deploy_service_scripts
      case platform
      when 'ubuntu', 'centos'
        # configuration files for upstart scripts by build_from_source installation
        template "/etc/init/mesos-master.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "stop", :role => "master")
          mode 0644
          owner "root"
          group "root"
          notifies :reload, "service[mesos-master]", :delayed
        end

        template "/etc/init/mesos-slave.conf" do
          source "upstart.conf.for.mesosphere.erb"
          variables(:init_state => "stop", :role => "slave")
          mode 0644
          owner "root"
          group "root"
          notifies :reload, "service[mesos-slave]", :delayed
        end
      end
    end

    def activate_master_service_scripts
      case platform
      when 'ubuntu', 'centos'
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
      when 'ubuntu', 'centos'
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
          'ubuntu' => ["unzip", "libtool", "libltdl-dev", "autoconf", "automake", "libcurl3", "libcurl3-gnutls", "libcurl4-openssl-dev", "python-dev", "libsasl2-dev"],
          'centos' => ["python-devel", "java-1.7.0-openjdk-devel", "zlib-devel", "libcurl-devel", "openssl-devel", "cyrus-sasl-devel", "cyrus-sasl-md5"]
        },
        'dependency_recipes' => {
          'ubuntu' => ["java", "python", "build-essential", "maven"],
          'centos' => ["java", "python", "build-essential", "maven"]
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
      when 'ubuntu', 'centos'
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
      when 'ubuntu', 'centos'
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
