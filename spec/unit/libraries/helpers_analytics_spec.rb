# encoding: UTF-8

require 'spec_helper'

describe Server::Helpers::Analytics do
  let(:node) { Chef::Node.new }
  let(:mock_analytics_server_attributes) do
    {
      'analytics' => {
        'fqdn' => 'analytics-server.chef.io'
      }
    }
  end

  before do
    node.default['server-provisioning'] = cluster_data
    allow(FileUtils).to receive(:touch).and_return(true)
    allow(Chef::Node).to receive(:load).and_return(Chef::Node.new)
    allow(Chef::ServerAPI).to receive(:new).and_return(rest)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/analytics-server-chefspec')
      .and_return(analytics_node)
  end

  it 'return the analytics hostname for a machine resource' do
    expect(described_class.analytics_server_hostname(node)).to eq 'analytics-server-chefspec'
  end

  it 'return the analytics fqdn' do
    expect(described_class.analytics_server_fqdn(node)).to eq 'analytics-server.chef.io'
  end

  it 'return the PATH of the analytics lock file' do
    expect(described_class.analytics_lock_file(node)).to eq File.join(Chef::Config.chef_repo_path, '.chef', 'provisioning-data-chefspec', 'analytics')
  end

  context 'when analytics' do
    context 'is NOT enabled' do
      before { allow(File).to receive(:exist?).and_return(false) }

      it 'say that analytics component is NOT enabled' do
        expect(described_class.analytics_enabled?(node)).to eq false
      end

      it 'return NO attributes' do
        expect(described_class.analytics_server_attributes(node)).to eq({})
      end
    end

    context 'is enabled' do
      before { allow(File).to receive(:exist?).and_return(true) }

      it 'say that analytics component is enabled' do
        expect(described_class.analytics_enabled?(node)).to eq true
      end

      it 'return the analytics attributes' do
        expect(described_class.analytics_server_attributes(node)).to eq('chef-server-12' => mock_analytics_server_attributes)
      end
    end
  end

  it 'activate analytics by creating the lock file' do
    expect(described_class.activate_analytics(node)).to eq true
  end
end
