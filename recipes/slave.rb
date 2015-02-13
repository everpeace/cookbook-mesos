#
# Cookbook Name:: mesos
# Recipe:: slave
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

directory deploy_dir do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  recursive true
end

include_mesos_recipe

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

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template File.join(deploy_dir, "mesos-slave-env.sh") do
  source "mesos-slave-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :reload,  "service[mesos-slave]", :delayed
  notifies :restart, "service[mesos-slave]", :delayed
end

activate_slave_service_scripts

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
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
      next if %w(master_url
                 master
                 isolation
                 log_dir).include?(key)
      next if val.nil?
      if val.respond_to?(:to_path_hash)
        val.to_path_hash.each do |path_h|
          attr_path = File.join('', 'etc', 'mesos-slave', key, path_h[:path])
          directory File.dirname(attr_path) do
            owner 'root'
            group 'root'
            mode 0755
          end

          file attr_path do
            content "#{path_h[:content]}\n"
            mode 0644
            user 'root'
            group 'root'
          end
        end
      else
        file File.join('', 'etc', 'mesos-slave', key) do
          content "#{val}\n"
          mode 0644
          user 'root'
          group 'root'
        end
      end
    end
  end
end
