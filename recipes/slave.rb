#
# Cookbook Name:: mesos
# Recipe:: slave
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#

prefix = node[:mesos][:prefix]
deploy_dir = File.join(prefix, "var", "mesos", "deploy")
installed = File.exists?(File.join(prefix, "sbin", "mesos-master"))

if !installed then
  include_recipe "mesos::build_from_source"
end

template File.join(deploy_dir, "mesos-deploy-env.sh") do
  source "mesos-deploy-env.sh.erb"
  mode 644
  owner "root"
  group "root"
end

template File.join(deploy_dir, "mesos-slave-env.sh") do
  source "mesos-slave-env.sh.erb"
  mode 644
  owner "root"
  group "root"
end


