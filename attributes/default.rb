default[:mesos] = {
  :type    => "source",
  :mesosphere => {
    :with_zookeeper => false
  },
  :version => "0.17.0",
  :prefix  => "/usr/local",
  :home => "/opt",
  :build   => {
    :skip_test => true
  },
  :master_ips => [],
  :slave_ips  => [],
  :master  => {
    :log_dir  => "/var/log/mesos",
    :port     => "5050"
  },
  :slave   => {
    :log_dir  => "/var/log/mesos",
    :work_dir => "/tmp/mesos",
    :isolation=> "cgroups"
  },
  :ssh_opts => "-o StrictHostKeyChecking=no -o ConnectTimeout=2",
  :deploy_with_sudo => "1"
}
