#
# Cookbook Name:: mesos
# Recipe:: default
#

if node['mesos']['type'] == 'source' then
  include_recipe "mesos::build_from_source"
elsif node['mesos']['type'] == 'mesosphere' then
  include_recipe "mesos::mesosphere"
else
  Chef::Application.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end
