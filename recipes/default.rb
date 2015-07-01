#
# Cookbook Name:: mesos
# Recipe:: default
#

# Avoid running on unsupported systems
unless %w(ubuntu centos).include? node["platform"]
  Chef::Application.fatal! "#{node['platform']} is not supported on #{cookbook_name} cookbook"
end

# Fail early if an unsupported install type is specified
unless %w(source mesosphere)
  Chef::Application.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end

case node["platform"]
when "centos"
  include_recipe "yum"
when "ubuntu"
  include_recipe "apt"
end

include_recipe "java"
include_recipe "mesos::#{node[:mesos][:type]}"
