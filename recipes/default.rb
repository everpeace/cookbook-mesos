#
# Cookbook Name:: mesos
# Recipe:: default
#

# Fail early if an unsupported install type is specified
unless %w(source mesosphere)
  Chef::Application.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end
include_recipe "mesos::#{node[:mesos][:type]}"
