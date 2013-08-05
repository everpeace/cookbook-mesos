name             'mesos'
maintainer       'Shingo Omura'
maintainer_email 'everpeace@gmail.com'
license          'All rights reserved'
description      'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
supports         'ubuntu'
recipe           "mesos::install", "install mesos(default recipe)."
recipe           "mesos::master",  "configure the machine as master."
recipe           "mesos::slave",   "configure the machine as slave."

depends          'java'
depends          'python'
depends          'build-essential'

attributes          "mesos/version",
  :recipes       => ["mesos::install"],
  :display_name  => "Version to be installed.",
  :description   => "branch name or tag name at http://github.com/apache/mesos",
  :default       => "master"

attributes          "mesos/prefix",
  :recipes       => ["mesos::install", "mesos::master", "mesos::slave"],
  :display_name  => "Prefix value to be passed to configure script",
  :description   => "prefix value to be passed to configure script",
  :default       => "/usr/local"

attributes          "mesos/build/skip_test",
  :recipes       => ["mesos::install"],
  :display_name  => "Flag whether test will be performed.",
  :description   => "if true, test will be skipped.",
  :default       => "true"

attributes          "mesos/ssh_opts",
  :recipes       => ["mesos::master"],
  :display_name  => "ssh options",
  :description   => "passed to be mesos-deploy-env.sh",
  :default       => "-o StrictHostKeyChecking=no -o ConnectTimeout=2"

attributes          "mesos/deploy_with_sudo",
  :recipes       => ["mesos::master"],
  :display_name  => "Flag whether sudo will be used in mesos deploy scripts",
  :description   => "Flag whether sudo will be used in mesos deploy scripts",
  :default       => "1"

attributes          "mesos/cluster_name",
  :recipes       => ["mesos::master"],
  :display_name  => "cluster name",
  :description   => "Human readable name for the cluster, displayed at webui"

attributes          "mesos/master/zk",
  :recipes       => ["mesos::master"],
  :display_name  => "zookeeper url",
  :description   => "ZooKeeper URL (used for leader election amongst masters)"

attributes          "mesos/master_ips",
  :recipes       => ["mesos::master"],
  :display_name  => "IP list of masters",
  :description   => "used in mesos-start/stop-cluster scripts."

attributes          "mesos/slave_ips",
  :recipes       => ["mesos::master"],
  :display_name  => "IP list of slaves",
  :description   => "used in mesos-start/stop-cluster scripts."

attributes          "mesos/master/ip",
  :recipes       => ["mesos::master"],
  :display_name  => "mater listen ip.",
  :description   => "IP address to listen on"

attributes          "mesos/master/log_dir",
  :recipes       => ["mesos::master"],
  :display_name  => "log_dir for master.",
  :description   => "Location to put log files.",
  :default       => "/var/log/mesos"

attributes          "mesos/slave/master_url",
  :required      => "required",
  :recipes       => ["mesos::slave"],
  :display_name  => "master url",
  :description   => "mesos master url. this should  be host:port for non-ZooKeeper based masters, otherwise a zk:// or file://."

attributes          "mesos/slave/ip",
  :recipes       => ["mesos::slave"],
  :display_name  => "slave listen ip.",
  :description   => "IP address to listen on"

attributes          "mesos/slave/log_dir",
  :recipes       => ["mesos::slave"],
  :display_name  => "log_dir for slave.",
  :description   => "Location to put log files.",
  :default       => "/var/log/mesos"

attributes          "mesos/slave/work_dir",
  :recipes       => ["mesos::slave"],
  :display_name  => "work_dir for slave.",
  :description   => "Where to place framework work directories.",
  :default       => "/var/run/mesos"

attributes          "mesos/slave/isolation",
  :recipes       => ["mesos::slave"],
  :display_name  => "Resource isolation mechanism.",
  :description   => "Isolation mechanism, may be one of: process, cgroups",
  :default       => "cgroups"


