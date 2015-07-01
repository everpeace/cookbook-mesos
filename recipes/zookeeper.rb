#
# Cookbook Name:: mesos
# Recipe:: zookeeper
#

case node["platform"]
when "centos"
  yum_repository "cdh" do
    description "Cloudera's Distribution for Hadoop, Version 4"
    url "http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/4/"
    gpgkey "http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera"
  end

  %w(
    zookeeper
    zookeeper-server
  ).each do |pkg|
    package pkg
  end

  execute "service zookeeper-server init || true"

  service "zookeeper-server" do
    provider Chef::Provider::Service::Init
    action :restart
  end
when 'ubuntu'
  %w(
    zookeeper
    zookeeperd
    zookeeper-bin
  ).each do |pkg|
    package pkg
  end

  service "zookeeper" do
    provider Chef::Provider::Service::Upstart
    action :restart
  end
end
