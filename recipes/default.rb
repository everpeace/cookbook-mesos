#
# Cookbook Name:: mesos
# Recipe:: default
#
# Copyright 2013, Shingo Omura
#
# All rights reserved - Do Not Redistribute
#

if node['mesos']['type'] == 'source' then
  include_recipe "mesos::build_from_source"
elsif node['mesos']['type'] == 'mesosphere' then
  include_recipe "mesos::mesosphere"
else
  Chef::Log.fatal!("node['mesos']['type'] should be 'source' or 'mesosphere'.")
end

