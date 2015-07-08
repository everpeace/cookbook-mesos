#
# Cookbook Name:: mesos
# Recipe:: mesosphere
#

include_recipe 'mesos::zookeeper' if node[:mesos][:mesosphere][:with_zookeeper]

case node['platform']
when "centos"
  repo_url = value_for_platform(
    'centos' => {
      'default' => 'http://repos.mesosphere.io/el/6/noarch/',
      '~> 7.0' => 'http://repos.mesosphere.io/el/7/noarch/'
    }
  )

  yum_repository 'mesosphere-noarch' do
    description 'Mesosphere repo'
    baseurl repo_url
  end

  yum_package "mesos >= #{node[:mesos][:version]}"
when 'ubuntu'
  apt_repository 'mesosphere' do
    uri "http://repos.mesosphere.com/#{node['platform']}"
    components [node['lsb']['codename'], 'main']
    keyserver 'keyserver.ubuntu.com'
    key 'E56151BF'
  end

  package "mesos" do
    version "#{node[:mesos][:version]}-1.0.#{node['platform']}#{node['platform_version'].sub '.', ''}"
  end
end
