#
# Cookbook Name:: mesos
# Recipe:: master
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#
::Chef::Recipe.send(:include, Helpers::Mesos)
if node[:mesos][:type] == 'source' then
  ::Chef::Recipe.send(:include, Helpers::Source)
elsif node[:mesos][:type] == 'mesosphere' then
  ::Chef::Recipe.send(:include, Helpers::Mesosphere)
  Chef::Log.info("node[:mesos][:prefix] is ignored. prefix will be set with /usr/local .")
else
  Chef::Application.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end

deploy_dir = File.join(prefix, "var", "mesos", "deploy")

include_mesos_recipe

# for backword compatibility
if node[:mesos][:cluster_name] then
  if !node[:mesos][:master][:cluster] then
    Chef::Log.info("node[:mesos][:cluster_name] is obsolute. use node[:mesos][:master][:cluster] instead.")
    node.default[:mesos][:master][:cluster] = node[:mesos][:cluster_name]
  else
    Chef::Log.info("node[:mesos][:cluster_name] is obsolute. node[:mesos][:cluster_name] will be ignored because you have node[:mesos][:master][:cluster].")
  end
end

if (! node[:mesos][:master][:zk]) then
  Chef::Application.fatal!("node[:mesos][:master][:zk] is required to configure mesos-master.")
end

if (! node[:mesos][:master][:quorum]) then
  Chef::Application.fatal!("node[:mesos][:master][:quorum] is required to configure mesos-master.")
end

# configuration files for mesos-[start|stop]-cluster.sh provided by both source and mesosphere
template File.join(deploy_dir, "masters") do
  source "masters.erb"
  mode 0644
  owner "root"
  group "root"
end

template File.join(deploy_dir, "slaves") do
  source "slaves.erb"
  mode 0644
  owner "root"
  group "root"
end

template File.join(deploy_dir, "mesos-deploy-env.sh") do
  source "mesos-deploy-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
end

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template File.join(prefix, "var", "mesos", "deploy", "mesos-master-env.sh") do
  source "mesos-master-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :reload,  "service[mesos-master]", :delayed
  notifies :restart, "service[mesos-master]", :delayed
end

activate_master_service_scripts

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
if node[:mesos][:type] == 'mesosphere' then
  # these template resources don't notify service resource because
  # changes of configuration can be detected in mesos-master-env.sh
  template File.join("/etc", "mesos", "zk") do
    source "etc-mesos-zk.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :zk => node[:mesos][:master][:zk]
    })
  end

  template File.join("/etc", "default", "mesos") do
    source "etc-default-mesos.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :log_dir => node[:mesos][:master][:log_dir]
    })
  end

  template File.join("/etc", "default", "mesos-master") do
    source "etc-default-mesos-master.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :port => node[:mesos][:master][:port]
    })
  end

  directory File.join("/etc", "mesos-master") do
    action :create
    recursive true
    mode 0755
    owner "root"
    group "root"
  end

  bash "cleanup /etc/mesos-master/" do
    code "rm -rf /etc/mesos-master/*"
    user "root"
    group "root"
    action :run
  end

  if node[:mesos][:master] then
    node[:mesos][:master].each do |key, val|
      if ! ['zk', 'log_dir', 'port'].include?(key) then
        _code = "echo #{val} > /etc/mesos-master/#{key}"
        bash _code do
          code _code
          user "root"
          group "root"
          action :run
        end
      end
    end
  end
end
