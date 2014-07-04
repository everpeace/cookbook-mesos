#
# Cookbook Name:: mesos
# Recipe:: mesosphere
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#
::Chef::Recipe.send(:include, Helpers::Mesos)
::Chef::Recipe.send(:include, Helpers::Mesosphere)
Chef::Resource::Service.send(:include, Helpers::Mesos)

# For now we need to use the latest 13.x based deb
# package until a trusty mesos deb is available
# from the mesosphere site.
if platform?("ubuntu") && node['platform_version'] == '14.04'
  platform_version = '13.10'
else
  platform_version = node['platform_version']
end

# TODO(everpeace) platform_version validation
if !platform_supported? then
  Chef::Application.fatal!("#{platform} is not supported on #{cookbook_name} cookbook")
end

if installed? then
  Chef::Log.info("Mesos is already installed!! Instllation will be skipped.")
end

# install dependencies and unzip
install_dependencies

# workaround for "error while loading shared libraries: libjvm.so: cannot open shared object file: No such file or directory"
link "/usr/lib/libjvm.so" do
  to "/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so"
  not_if "test -L /usr/lib/libjvm.so"
end

if node['mesos']['mesosphere']['with_zookeeper'] then
  install_zookeeper
end

install_mesos
deploy_service_scripts

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
