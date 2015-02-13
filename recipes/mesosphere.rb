#
# Cookbook Name:: mesos
# Recipe:: mesosphere
#

::Chef::Recipe.send(:include, Helpers::Mesos)
::Chef::Recipe.send(:include, Helpers::Mesosphere)
Chef::Resource::Service.send(:include, Helpers::Mesos)

# TODO(everpeace) platform_version validation
if !platform_supported? then
  Chef::Application.fatal!("#{platform} is not supported on #{cookbook_name} cookbook")
end

if !(installed?) then
  if node['mesos']['mesosphere']['with_zookeeper'] then
    install_zookeeper
  end

  install_mesos
  deploy_service_scripts
else
  Chef::Log.info("Mesos is already installed!! Installation will be skipped.")
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
