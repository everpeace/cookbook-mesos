#
# Cookbook Name:: mesos
# Recipe:: mesosphere
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#
version = node[:mesos][:version]
supported_mesos = ['0.14.0','0.14.1', '0.14.2', '0.15.0-rc4', '0.15.0-rc5', '0.15.0', '0.16.0-rc2', '0.16.0-rc3']
download_url = "http://downloads.mesosphere.io/master/#{node['platform']}/#{node['platform_version']}/mesos_#{version}_amd64.deb"

# TODO(everpeace) platform_version validation
if !platform?("ubuntu") then
  Chef::Application.fatal!("#{platform} is not supported on #{cookbook_name} cookbook")
end
if !supported_mesos.include?(version) then
  Chef::Application.fatal!("#{version} is not supported on #{cookbook_name}::#{recipe_name}")
end

installed = File.exist?("/usr/local/sbin/mesos-master")
if installed then
  Chef::Log.info("Mesos is already installed!! Instllation will be skipped.")
end

# Needed for installing mesos using dpkg on Ubuntu 12.04,
# and perhaps Ubuntu 13.04 as well (not tested though)
package 'libcurl3'

apt_package "default-jre-headless" do
  action :install
  not_if { installed==true }
end

# workaround for "error while loading shared libraries: libjvm.so: cannot open shared object file: No such file or directory"
link "/usr/lib/libjvm.so" do
  to "/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so"
  not_if "test -L /usr/lib/libjvm.so"
end

if node['mesos']['mesosphere']['with_zookeeper'] then
  ['zookeeper', 'zookeeperd', 'zookeeper-bin'].each do |zk|
    package zk do
      action :install
    end
   end
   service "zookeeper" do
      provider Chef::Provider::Service::Upstart
      action :restart
   end
 end

remote_file "#{Chef::Config[:file_cache_path]}/mesos_#{version}.deb" do
  source "#{download_url}"
  mode   0644
  not_if { installed==true }
  notifies :install, "dpkg_package[mesos]"
end

dpkg_package "mesos" do
  source "#{Chef::Config[:file_cache_path]}/mesos_#{version}.deb"
  action :install
  not_if { installed==true }
end
