# encoding: utf-8

shared_examples_for 'a master node' do
  describe 'masters file' do
    let :masters_file do
      file '/usr/local/var/mesos/deploy/masters'
    end

    it 'creates it' do
      expect(masters_file).to be_a_file
    end

    it 'contains a newline separated list of configured master IPs' do
      expect(masters_file.content).to match(/^10.0.0.1$/)
      expect(masters_file.content).to match(/^10.0.0.2$/)
      expect(masters_file.content).to match(/^10.0.0.3$/)
    end
  end

  describe 'slaves file' do
    let :slaves_file do
      file '/usr/local/var/mesos/deploy/slaves'
    end

    it 'creates it' do
      expect(slaves_file).to be_a_file
    end

    it 'contains a newline separated list of configured master IPs' do
      expect(slaves_file.content).to match(/^10.0.0.4$/)
      expect(slaves_file.content).to match(/^10.0.0.5$/)
      expect(slaves_file.content).to match(/^10.0.0.6$/)
    end
  end

  describe 'deploy env template' do
    let :deploy_env_file do
      file('/usr/local/var/mesos/deploy/mesos-deploy-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(deploy_env_file).to be_a_file
    end

    it 'contains SSH_OPTS variable' do
      expect(deploy_env_file.content).to match(/^export SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=2"$/)
    end

    it 'contains DEPLOY_WITH_SUDO variable' do
      expect(deploy_env_file.content).to match(/^export DEPLOY_WITH_SUDO="1"$/)
    end
  end

  describe 'master env template' do
    let :master_env_file do
      file('/usr/local/var/mesos/deploy/mesos-master-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(master_env_file).to be_a_file
    end

    it 'contains log_dir variable' do
      expect(master_env_file.content).to match %r{^export MESOS_log_dir=/var/log/mesos$}
    end

    it 'contains port variable' do
      expect(master_env_file.content).to match(/^export MESOS_port=5050$/)
    end
  end

  context 'master upstart script' do
    describe file '/etc/init/mesos-master.conf' do
      it { is_expected.to be_file }
    end
  end

  describe service('mesos-master') do
    it { should be_enabled }
    it { should be_running }
  end
end
