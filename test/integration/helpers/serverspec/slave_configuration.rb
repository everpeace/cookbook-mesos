# encoding: utf-8

shared_examples_for 'a configuration of a slave node' do
  describe 'deploy env template' do
    let :deploy_env_file do
      file('/usr/local/var/mesos/deploy/mesos-deploy-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(deploy_env_file).to be_a_file
    end

    it 'contains SSH_OPTS variable' do
      expect(deploy_env_file.content).to match /^export SSH_OPTS="#{Regexp.escape('-o StrictHostKeyChecking=no -o ConnectTimeout=2')}"$/
    end

    it 'contains DEPLOY_WITH_SUDO variable' do
      expect(deploy_env_file.content).to match /^export DEPLOY_WITH_SUDO="1"$/
    end
  end

  describe 'slave env template' do
    let :slave_env_file do
      file('/usr/local/var/mesos/deploy/mesos-slave-env.sh')
    end

    it 'creates it in deploy directory' do
      expect(slave_env_file).to be_a_file
    end

    it 'contains log_dir variable' do
      expect(slave_env_file.content).to match /^export MESOS_log_dir=\/var\/log\/mesos$/
    end

    it 'contains work_dir variable' do
      expect(slave_env_file.content).to match /^export MESOS_work_dir=\/tmp\/mesos$/
    end

    it 'contains isolation variable' do
      expect(slave_env_file.content).to match /^export MESOS_isolation=cgroups\/cpu,cgroups\/mem$/
    end

    it 'contains rackid variable' do
      expect(slave_env_file.content).to match(/^export MESOS_attributes_rackid=us-east-1b$/)
    end
  end

  describe 'rack id file' do
    let :rack_id_file do
      file '/etc/mesos-slave/attributes/rackid'
    end

    it 'creates it' do
      expect(rack_id_file).to be_a_file
    end

    it 'contains a rack id' do
      expect(rack_id_file.content).to match(/^us-east-1b$/)
    end
  end

  describe service('mesos-slave') do
    it { should be_enabled }
    # service mesos-master is required in order which the below was passed.
    it { should be_running }
  end
end
