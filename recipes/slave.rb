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
  prefix = File.join("/usr", "local")
  Chef::Log.info("node[:mesos][:prefix] is ignored. prefix will be set with /usr/local .")
else
  Chef::Application.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
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

# for backword compatibility
if node[:mesos][:slave][:master_url] then
  if !node[:mesos][:slave][:master] then
    Chef::Log.info("node[:mesos][:slave][:master_url] is obsolute. use node[:mesos][:slave][:master] instead.")
    node.default[:mesos][:slave][:master] = node[:mesos][:slave][:master_url]
  else
    Chef::Log.info("node[:mesos][:slave][:master_url] is obsolute. node[:mesos][:slave][:master_url] will be ignored because you have node[:mesos][:slave][:master].")
  end
end

if ! node[:mesos][:slave][:master] then
  Chef::Application.fatal!("node[:mesos][:slave][:master] is required to configure mesos-slave.")
end

template File.join(deploy_dir, "mesos-deploy-env.sh") do
  source "mesos-deploy-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
end

template File.join(deploy_dir, "mesos-slave-env.sh") do
  source "mesos-slave-env.sh.erb"
  mode 0644
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
      :zk => node[:mesos][:slave][:master]
    })
  end

  template File.join("/etc", "default", "mesos") do
    source "etc-default-mesos.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :log_dir => node[:mesos][:slave][:log_dir]
    })
  end

  template File.join("/etc", "default", "mesos-slave") do
    source "etc-default-mesos-slave.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :isolation => node[:mesos][:slave][:isolation]
    })
  end

  directory File.join("/etc", "mesos-slave") do
    action :create
    recursive true
    mode 0755
    owner "root"
    group "root"
  end

  bash "cleanup /etc/mesos-slave/" do
    code "rm -rf /etc/mesos-slave/*"
    user "root"
    group "root"
    action :run
  end

  if node[:mesos][:slave] then
    node[:mesos][:slave].each do |key, val|
      if ! ['master_url', 'master', 'isolation', 'log_dir'].include?(key) then
        _code = "echo #{val} > /etc/mesos-slave/#{key}"
        bash _code do
          code _code
          user "root"
          group "root"
          action :run
        end
      end
    end
  end

 service "mesos-slave" do
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end
