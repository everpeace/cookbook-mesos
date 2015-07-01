#
# Cookbook Name:: mesos
# Recipe:: master
#

::Chef::Recipe.send(:include, ::Helpers::Mesos)
if node[:mesos][:type] == 'source' then
  ::Chef::Recipe.send(:include, ::Helpers::Source)
elsif node[:mesos][:type] == 'mesosphere' then
  ::Chef::Recipe.send(:include, ::Helpers::Mesosphere)
  Chef::Log.info("node[:mesos][:prefix] is ignored. prefix will be set with /usr/local .")
end
include_recipe "mesos::default"

deploy_dir = node[:mesos][:deploy_dir]

directory deploy_dir do
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  recursive true
end

# for backwards compatibility
if node[:mesos][:cluster_name] then
  if !node[:mesos][:master][:cluster] then
    Chef::Log.info 'node[:mesos][:cluster_name] is obsolete. use node[:mesos][:master][:cluster] instead.'
    node.default[:mesos][:master][:cluster] = node[:mesos][:cluster_name]
  else
    Chef::Log.info 'node[:mesos][:cluster_name] is obsolete. node[:mesos][:cluster_name] will be ignored because you have node[:mesos][:master][:cluster].'
  end
end

if (! node[:mesos][:master][:zk]) then
  Chef::Application.fatal!("node[:mesos][:master][:zk] is required to configure mesos-master.")
end

if (! node[:mesos][:master][:quorum]) then
  Chef::Application.fatal!("node[:mesos][:master][:quorum] is required to configure mesos-master.")
end

# configuration files for mesos-[start|stop]-cluster.sh provided
# by both source and mesosphere
template "#{deploy_dir}/masters" do
  source "masters.erb"
  mode 0644
  owner "root"
  group "root"
end

template "#{deploy_dir}/slaves" do
  source "slaves.erb"
  mode 0644
  owner "root"
  group "root"
end

template "#{deploy_dir}/mesos-deploy-env.sh" do
  source "mesos-deploy-env.sh.erb"
  mode 0644
  owner "root"
  group "root"
end

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-master-env.sh" do
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
  template "/etc/mesos/zk" do
    source "etc-mesos-zk.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :zk => node[:mesos][:master][:zk]
    })
  end

  template "/etc/default/mesos" do
    source "etc-default-mesos.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :log_dir => node[:mesos][:master][:log_dir]
    })
  end

  template "/etc/default/mesos-master" do
    source "etc-default-mesos-master.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :port => node[:mesos][:master][:port]
    })
  end

  directory "/etc/mesos-master" do
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
      next if %w(zk
                 log_dir
                 port).include?(key)
      next if val.nil?
      if val.respond_to?(:to_path_hash)
        val.to_path_hash.each do |path_h|
          attr_path = "/etc/mesos-master/#{key}"

          directory attr_path do
            owner 'root'
            group 'root'
            mode 0755
          end

          file "#{attr_path}/#{path_h[:path]}" do
            content "#{path_h[:content]}\n"
            mode 0644
            user 'root'
            group 'root'
          end
        end
      else
        file "/etc/mesos-master/#{key}" do
          content "#{val}\n"
          mode 0644
          user 'root'
          group 'root'
        end
      end
    end
  end
end
