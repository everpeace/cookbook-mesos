default[:mesos] = {
  :type    => "source",
  :version => "0.15.0-rc4",
  :prefix  => "/usr/local",
  :home => "/opt",
  :cluster_name => "MyCluster",
  :build   => {
    :skip_test => true
  },
  :master_ips => [],
  :slave_ips  => [],
  :master  => {
    :log_dir  => "/var/log/mesos"
  },
  :slave   => {
    :log_dir  => "/var/log/mesos",
    :work_dir => "/var/run/mesos",
    :isolation=> "cgroups"
  },
  :ssh_opts => "-o StrictHostKeyChecking=no -o ConnectTimeout=2",
  :deploy_with_sudo => "1",
}
