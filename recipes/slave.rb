#
# Cookbook Name:: mesos
# Recipe:: slave
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#

if node[:mesos][:type] == 'source' then
  prefix = node[:mesos][:prefix]
elsif node[:mesos][:type] == 'mesosphere' then
  prefix = File.join("usr","local")
  Chef::Log.info("node[:mesos][:prefix] is ignored. prefix will be set with /usr/local .")
else
  Chef::Log.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end

deploy_dir = File.join(prefix, "var", "mesos", "deploy")
installed = File.exists?(File.join(prefix, "sbin", "mesos-master"))

if !installed then
  if node[:mesos][:type] == 'source' then
    include_recipe "mesos::build_from_source"
  elsif node[:mesos][:type] == 'mesosphere'
    include_recipe "mesos::mesosphere"
  end
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

# configuration files for upstart scripts by mesosphere package.
if node[:mesos][:type] == 'mesosphere' then
  template File.join("/etc", "mesos", "zk") do
    source "etc-mesos-zk.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :zk => node[:mesos][:slave][:master_url]
    })
  end

  template File.join("/etc", "default", "mesos") do
    source "etc-default-mesos.erb"
    mode 644
    owner "root"
    group "root"
    variables({
      :log_dir => node[:mesos][:slave][:log_dir]
    })
  end

  template File.join("/etc", "default", "mesos-slave") do
    source "etc-default-mesos-slave.erb"
    mode 644
    owner "root"
    group "root"
  end

  service "mesos-slave" do
    provider Chef::Provider::Service::Upstart
    action :start
  end
end


