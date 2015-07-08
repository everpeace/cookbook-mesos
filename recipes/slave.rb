#
# Cookbook Name:: mesos
# Recipe:: slave
#

include_recipe "mesos::default"

service "mesos-slave" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :reload => true
  action :nothing
end

deploy_dir = node[:mesos][:deploy_dir]

directory deploy_dir do
  recursive true
end

# for backword compatibility
if node[:mesos][:slave][:master_url] then
  if !node[:mesos][:slave][:master] then
    Chef::Log.info 'node[:mesos][:slave][:master_url] is obsolete. use node[:mesos][:slave][:master] instead.'
    node.default[:mesos][:slave][:master] = node[:mesos][:slave][:master_url]
  else
    Chef::Log.info 'node[:mesos][:slave][:master_url] is obsolete. node[:mesos][:slave][:master_url] will be ignored because you have node[:mesos][:slave][:master].'
  end
end

if ! node[:mesos][:slave][:master] then
  fail 'node[:mesos][:slave][:master] is required to configure mesos-slave.'
end

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-slave-env.sh" do
  source "mesos-slave-env.sh.erb"
  notifies :reload,  "service[mesos-slave]", :delayed
  notifies :restart, "service[mesos-slave]", :delayed
end

template "/etc/init/mesos-slave.conf" do
  source "upstart.conf.for.#{node[:mesos][:type]}.erb"
  variables :init_state => "start", :role => "slave"
  notifies :reload, "service[mesos-slave]"
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere package.
if node[:mesos][:type] == 'mesosphere' then
  template "/etc/mesos/zk" do
    source "etc-mesos-zk.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :zk => node[:mesos][:slave][:master]
    })
  end

  template "/etc/default/mesos" do
    source "etc-default-mesos.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :log_dir => node[:mesos][:slave][:log_dir]
    })
  end

  template "/etc/default/mesos-slave" do
    source "etc-default-mesos-slave.erb"
    mode 0644
    owner "root"
    group "root"
    variables({
      :isolation => node[:mesos][:slave][:isolation]
    })
  end

  directory "/etc/mesos-slave" do
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
          attr_path = "/etc/mesos-slave/#{key}"

          directory "#{attr_path}" do
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
        file "/etc/mesos-slave/#{key}" do
          content "#{val}\n"
          mode 0644
          user 'root'
          group 'root'
        end
      end
    end
  end
end
