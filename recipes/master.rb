#
# Cookbook Name:: mesos
# Recipe:: master
#

include_recipe "mesos::default"

deploy_dir = node[:mesos][:deploy_dir]

directory deploy_dir do
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
  fail 'node[:mesos][:master][:zk] is required to configure mesos-master.'
end

if (! node[:mesos][:master][:quorum]) then
  fail 'node[:mesos][:master][:quorum] is required to configure mesos-master.'
end

# configuration files for mesos-[start|stop]-cluster.sh provided
# by both source and mesosphere
template "#{deploy_dir}/masters"

template "#{deploy_dir}/slaves"

template "#{deploy_dir}/mesos-deploy-env.sh"

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-master-env.sh" do
  notifies :reload,  "service[mesos-master]"
  notifies :restart, "service[mesos-master]"
end

template "/etc/init/mesos-master.conf" do
  source "upstart.conf.for.#{node[:mesos][:type]}.erb"
  variables :init_state => "start", :role => "master"
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
if node[:mesos][:type] == 'mesosphere' then
  # these template resources don't notify service resource because
  # changes of configuration can be detected in mesos-master-env.sh
  template "/etc/mesos/zk" do
    source "etc-mesos-zk.erb"
    variables(
      :zk => node[:mesos][:master][:zk]
    )
  end

  template "/etc/default/mesos" do
    source "etc-default-mesos.erb"
    variables(
      :log_dir => node[:mesos][:master][:log_dir]
    )
  end

  template "/etc/default/mesos-master" do
    source "etc-default-mesos-master.erb"
    variables(
      :port => node[:mesos][:master][:port]
    )
  end

  directory "/etc/mesos-master" do
    recursive true
  end

  # TODO Refactor this to be idempotent, or have a guard - jeffbyrnes
  execute "rm -rf /etc/mesos-master/*"

  node[:mesos][:master].each do |key, val|
    next if %w(zk log_dir port).include? key
    next if val.nil?
    if val.respond_to? :to_path_hash
      val.to_path_hash.each do |path_h|
        attr_path = "/etc/mesos-master/#{key}"

        directory attr_path

        file "#{attr_path}/#{path_h[:path]}" do
          content "#{path_h[:content]}\n"
        end
      end
    else
      file "/etc/mesos-master/#{key}" do
        content "#{val}\n"
      end
    end
  end
end
