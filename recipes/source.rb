#
# Cookbook Name:: mesos
# Recipe:: install
#

%w(
  python
  build-essential
  maven
).each do |r|
  include_recipe r
end

case node["platform"]
when "centos"
  pkgs = %w(
    python-devel
    zlib-devel
    libcurl-devel
    openssl-devel
    cyrus-sasl-devel
    cyrus-sasl-md5
  )
when "ubuntu"
  pkgs = %w(
    unzip
    libtool
    libltdl-dev
    automake
    libcurl3
    libcurl3-gnutls
    libcurl4-openssl-dev
    libsasl2-dev
    python-boto
  )
end

pkgs.each do |pkg|
  package pkg
end

mesos_version = node[:mesos][:version]
prefix = node[:mesos][:prefix]
cmd = "#{prefix}/mesos-master --version |cut -f 2 -d ' '"

unless File.exist?("#{prefix}/mesos-master") && (`#{cmd}`.chop == mesos_version)
  remote_file "#{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip" do
    source "https://github.com/apache/mesos/archive/#{mesos_version}.zip"
  end

  execute "extract mesos to #{node[:mesos][:home]}" do
    cwd    "#{node[:mesos][:home]}"
    command "unzip -o #{Chef::Config[:file_cache_path]}/mesos-#{mesos_version}.zip -d ./" \
             " && mv mesos-#{mesos_version} mesos"
  end

  execute 'build mesos from source' do
    cwd     "#{node[:mesos][:home]}/mesos"
    command "./bootstrap && mkdir -p build && cd build && ../configure --prefix=#{prefix} && make"
  end

  execute 'test mesos' do
    cwd     "#{node[:mesos][:home]}/mesos/build"
    command 'make check'
    not_if  { node[:mesos][:build][:skip_test] }
  end

  execute "install mesos to #{prefix}" do
    cwd     "#{node[:mesos][:home]}/mesos/build"
    command 'make install && ldconfig'
  end
end
