#
# Cookbook Name:: mesos
# Recipe:: docker-executor
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#

version = node[:mesos][:version]
egg_name = "mesos_#{version}_amd64"
if version =~ /^0\.14/ then
  egg_name = "mesos-#{version}-py2.7-linux-x86_64"
end

# this doesn't work. so we have to install docker manually outside. I can't figure out why.
include_recipe "docker"

package "python-setuptools" do
  action :install
end

remote_file "#{Chef::Config[:file_cache_path]}/#{egg_name}.egg" do
  source "http://downloads.mesosphere.io/master/ubuntu/13.04/#{egg_name}.egg"
  mode   "0755"
  not_if { File.exists?("#{Chef::Config[:file_cache_path]}/#{egg_name}.egg")==true }
  notifies :run,  "execute[install-mesos-python-binding]"
end

execute "install-mesos-python-binding" do
  command "easy_install #{Chef::Config[:file_cache_path]}/#{egg_name}.egg"
  not_if { ::File.exists?('/usr/local/lib/python2.7/dist-packages/mesos.egg') }
end

directory '/var/lib/mesos/executors' do
  owner 'root'
  group 'root'
  mode "0755"
  recursive true
  action :create
end

remote_file "/var/lib/mesos/executors/docker" do
  source "https://raw.github.com/mesosphere/mesos-docker/master/bin/mesos-docker"
  mode "0755"
  not_if { File.exists?("/var/lib/mesos/executor/docker")==true }
end

