#
# Cookbook Name:: mesos
# Recipe:: master
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
if node[:mesos][:cluster_name] then
  if !node[:mesos][:master][:cluster] then
    Chef::Log.info("node[:mesos][:cluster_name] is obsolute. use node[:mesos][:master][:cluster] instead.")
    node.default[:mesos][:master][:cluster] = node[:mesos][:cluster_name]
  else
    Chef::Log.info("node[:mesos][:cluster_name] is obsolute. node[:mesos][:cluster_name] will be ignored because you have node[:mesos][:master][:cluster].")
  end
end


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

template File.join(prefix, "var", "mesos", "deploy", "mesos-master-env.sh") do
  source "mesos-master-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :reload,  "service[mesos-master]", :delayed
  notifies :restart, "service[mesos-master]", :delayed
end

# configuration files for upstart scripts by build_from_source installation
if node[:mesos][:type] == 'source' then
  template "/etc/init/mesos-master.conf" do
    source "upstart.conf.for.buld_from_source.erb"
    variables(:init_state => "start", :role => "master")
    mode 0644
    owner "root"
    group "root"
  end
end

# configuration files for upstart scripts by mesosphere package.
if node[:mesos][:type] == 'mesosphere' then
  # these template resources don't notify service resource because
  # changes of configuration can be detected in mesos-master-env.sh
  template "/etc/init/mesos-master.conf" do
    source "upstart.conf.for.mesosphere.erb"
    variables(:init_state => "start", :role => "master")
    mode 0644
    owner "root"
    group "root"
  end

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

