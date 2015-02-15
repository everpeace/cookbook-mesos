name             'mesos'
maintainer       'Shingo Omura'
maintainer_email 'everpeace@gmail.com'
license          'MIT'
description      'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.2'

supports         'ubuntu', '>= 12.04'
supports         'centos', '>= 6.0'

recipe           "mesos::default", "install mesos."
recipe           "mesos::mesosphere", "install mesos from mesosphere package."
recipe           "mesos::build_from_source", "install mesos from source(default recipe)."
recipe           "mesos::master",  "configure the machine as master."
recipe           "mesos::slave",   "configure the machine as slave."
recipe           "mesos::docker-executor", "install mesos-docker executor"

depends          'java'
depends          'python'
depends          'build-essential'
depends          'maven'
depends          'ulimit'
suggests         'docker'
suggests         'zookeeper'

attribute           "mesos/type",
  :recipes       => ["mesos::build_from_source", "mesos::mesosphere", "mesos::master", "mesos::slave"],
  :display_name  => "installation type",
  :description   => "Value should be 'source' | 'mesosphere'.",
  :description   => "instlal type",
  :default       => "source"

attribute           "mesos/version",
  :recipes       => ["mesos::build_from_source", "mesos::mesosphere"],
  :display_name  => "Version to be installed.",
  :description   => "branch name or tag name at http://github.com/apache/mesos, or mesos's version name",
  :default       => "0.20.1"

attribute           "mesos/mesosphere/with_zookeeper",
  :recipes       => ["mesos::mesosphere"],
  :display_name  => "switch for installing zookeeper packages",
  :description   => "if true, zookeeper packages will be installed with mesosphere's mesos package",
  :default       => "false"

attribute           "mesos/prefix",
  :recipes       => ["mesos::build_from_source", "mesos::master", "mesos::slave"],
  :display_name  => "Prefix value to be passed to configure script",
  :description   => "prefix value to be passed to configure script",
  :default       => "/usr/local"

attribute           "mesos/home",
  :recipes       => ["mesos::build_from_source"],
  :display_name  => "mesos home directory",
  :description   => "directory which mesos sources are extracted to.",
  :default       => "/opt"

attribute           "mesos/build/skip_test",
  :recipes       => ["mesos::build_from_source"],
  :display_name  => "Flag whether test will be performed.",
  :description   => "if true, test will be skipped.",
  :default       => "true"

attribute           "mesos/ssh_opts",
  :recipes       => ["mesos::master"],
  :display_name  => "ssh options",
  :description   => "passed to be mesos-deploy-env.sh",
  :default       => "-o StrictHostKeyChecking=no -o ConnectTimeout=2"

attribute           "mesos/deploy_with_sudo",
  :recipes       => ["mesos::master"],
  :display_name  => "Flag whether sudo will be used in mesos deploy scripts",
  :description   => "Flag whether sudo will be used in mesos deploy scripts",
  :default       => "1"

attribute           "mesos/cluster_name",
  :recipes       => ["mesos::master"],
  :display_name  => "cluster name",
  :description   => "[OBSOLUTE] Human readable name for the cluster, displayed at webui"

attribute           "mesos/master_ips",
  :recipes       => ["mesos::master"],
  :display_name  => "IP list of masters",
  :description   => "used in mesos-start/stop-cluster scripts."

attribute           "mesos/slave_ips",
  :recipes       => ["mesos::master"],
  :display_name  => "IP list of slaves",
  :description   => "used in mesos-start/stop-cluster scripts."

attribute           "mesos/slave/master_url",
  :required      => "required",
  :recipes       => ["mesos::slave"],
  :display_name  => "master url",
  :description   => "[OBSOLUTE] Use mesos/slave/master.  mesos master url. this should  be host:port for non-ZooKeeper based masters, otherwise a zk:// or file://."
