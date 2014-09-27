default[:mesos] = {
  :type    => "source",
  :mesosphere => {
    :with_zookeeper => false
  },
  :version => "0.20.1",
  :prefix  => "/usr/local",
  :home => "/opt",
  :build   => {
    :skip_test => true
  },
  :master_ips => [],
  :slave_ips  => [],
  :master  => {
    :log_dir  => "/var/log/mesos",
    :work_dir => "/tmp/mesos",
    :port     => "5050"
  },
  :slave   => {
    :log_dir  => "/var/log/mesos",
    :work_dir => "/tmp/mesos",
    :isolation=> "cgroups/cpu,cgroups/mem"
  },
  :ssh_opts => "-o StrictHostKeyChecking=no -o ConnectTimeout=2",
  :deploy_with_sudo => "1"
}
