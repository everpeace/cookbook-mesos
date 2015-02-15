#
# Cookbook Name:: mesos
# Recipe:: install
#

::Chef::Recipe.send(:include, ::Helpers::Mesos)
::Chef::Recipe.send(:include, ::Helpers::Source)
Chef::Resource::Bash.send(:include, ::Helpers::Mesos)
Chef::Resource::Bash.send(:include, ::Helpers::Source)
Chef::Resource::RemoteFile.send(:include, ::Helpers::Mesos)
Chef::Resource::RemoteFile.send(:include, ::Helpers::Source)
Chef::Resource::Template.send(:include, ::Helpers::Mesos)
Chef::Resource::Template.send(:include, ::Helpers::Source)
Chef::Resource::Service.send(:include, ::Helpers::Mesos)
Chef::Resource::Service.send(:include, ::Helpers::Source)

if !(installed?) then
  include_dependency_recipes
  install_dependency_packages

  remote_file "#{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip" do
    source "#{download_url}"
    mode   "0644"
  end

  bash "extracting mesos to #{node[:mesos][:home]}" do
    cwd    "#{node[:mesos][:home]}"
    code   <<-EOH
      unzip -o #{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip -d ./
      mv mesos-#{mesos_version} mesos
    EOH
    action :run
  end

  bash "building mesos from source" do
    cwd   File.join("#{node[:mesos][:home]}", "mesos")
    code  <<-EOH
      ./bootstrap
      ./bootstrap
      mkdir -p build
      cd build
      ../configure --prefix=#{prefix}
      make
    EOH
    action :run
  end

  bash "testing mesos" do
    cwd    File.join("#{node[:mesos][:home]}", "mesos", "build")
    code   "make check"
    action :run
    only_if { node[:mesos][:build][:skip_test]==false }
  end

  bash "install mesos to #{prefix}" do
    cwd    File.join("#{node[:mesos][:home]}", "mesos", "build")
    code   <<-EOH
      make install
      ldconfig
    EOH
    action :run
  end

  # configuration files for upstart scripts by build_from_source installation
  template "/etc/init/mesos-master.conf" do
    source "upstart.conf.for.buld_from_source.erb"
    variables(:init_state => "stop", :role => "master")
    mode 0644
    owner "root"
    group "root"
    notifies :reload, "service[mesos-master]", :delayed
  end

  template "/etc/init/mesos-slave.conf" do
    source "upstart.conf.for.buld_from_source.erb"
    variables(:init_state => "stop", :role => "slave")
    mode 0644
    owner "root"
    group "root"
    notifies :reload, "service[mesos-slave]", :delayed
  end
else
  Chef::Log.info("Mesos is already installed!! Instllation will be skipped.")
end

service "mesos-master" do
  provider service_provider
  supports :restart => true, :reload => true
  action :nothing
end

service "mesos-slave" do
  provider service_provider
  supports :restart => true, :reload => true
  action :nothing
end
