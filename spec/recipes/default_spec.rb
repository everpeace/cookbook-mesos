# encoding: utf-8

require 'spec_helper'

describe 'mesos::default' do
  let :chef_run do
    ChefSpec::ServerRunner.new do |node|
      node.set[:mesos][:type] = :bork
    end
  end

  before do
    allow(Chef::Application).to receive(:fatal!)
  end

  context 'when type is neither `source` or `mesosphere`' do
    it 'exits the Chef run' do
      chef_run.converge(described_recipe)

      expect(Chef::Application).to have_received(:fatal!).with(/should be 'source' or 'mesosphere'/)
    end
  end
end
