# encoding: UTF-8

require 'chef/run_context'
require 'chef/event_dispatch/dispatcher'
require 'spec_helper'

describe Server::Helpers::Provisioner do
  let(:node) { Chef::Node.new }
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
  let(:mock_provisioner_artifact) do
    {
      'version' => '0.3.0',
      'artifact' => 'https://artifactory.chef.io/provisioner/provisioner-artifact-0.3.0.pkg',
      'checksum' => 'checksumchecksumchecksumchecksumchecksumchecksum'
    }
  end
  let(:extra_provisioner_attributes) do
    {
      'passed-something' => %w(super cool),
      'a-custom-attribute' => 'carambola',
      'port-for-something' => 1234
    }
  end
  before do
    node.default['server-provisioning'] = cluster_data
    allow(FileUtils).to receive(:touch).and_return(true)
    allow(Chef::Node).to receive(:load).and_return(Chef::Node.new)
    allow(Chef::ServerAPI).to receive(:new).and_return(rest)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/provisioner-server-chefspec')
      .and_return(provisioner_node)
  end

  it 'return the provisioner hostname for a machine resource' do
    expect(described_class.provisioner_server_hostname(node)).to eq 'provisioner-server-chefspec'
  end

  it 'return the provisioner fqdn' do
    expect(described_class.provisioner_server_fqdn(node)).to eq 'provisioner-server.chef.io'
  end

  it 'return the just the provisioner attributes without artifactory' do
    attributes = described_class.provisioner_server_attributes(node)
    expect(attributes['server-provisioning']['provisioner']['version']).to eq 'latest'
    expect(attributes['server-provisioning']['provisioner']['artifact']).to eq nil
    expect(attributes['server-provisioning']['provisioner']['checksum']).to eq nil
    expect(attributes['server-provisioning']['provisioner']['chef_server']).to eq 'https://chef-server.chef.io/organizations/chefspec'
    expect(attributes['server-provisioning']['provisioner']['fqdn']).to eq 'provisioner-server.chef.io'
  end

  context 'when we want to pull provisioner from artifactory' do
    before do
      node.default['server-provisioning']['provisioner']['artifactory'] = true
      allow(Server::Helpers::Provisioner).to receive(:provisioner_artifact).and_return(mock_provisioner_artifact)
    end

    it 'return the right provisioner attributes from artifactory' do
      attributes = described_class.provisioner_server_attributes(node)
      expect(attributes['server-provisioning']['provisioner']['version']).to eq(mock_provisioner_artifact['version'])
      expect(attributes['server-provisioning']['provisioner']['artifact']).to eq(mock_provisioner_artifact['artifact'])
      expect(attributes['server-provisioning']['provisioner']['checksum']).to eq(mock_provisioner_artifact['checksum'])
      expect(attributes['server-provisioning']['provisioner']['chef_server']).to eq 'https://chef-server.chef.io/organizations/chefspec'
      expect(attributes['server-provisioning']['provisioner']['fqdn']).to eq 'provisioner-server.chef.io'
    end
  end

  context 'when driver is NOT specified' do
    it 'raise a RuntimeError' do
      expect { described_class.provisioner_ctl(node) }.to raise_error(RuntimeError)
    end
  end

  context 'when driver is specified' do
    before do
      node.default['server-provisioning']['driver'] = 'ssh'
      node.default['server-provisioning']['ssh'] = ssh_data
    end

    context 'and Provisioner version' do
      context 'is > 0.2.52 or latest' do
        it 'return the provisioner-ctl command to create an enterprise with --ssh-pub-key-file' do
          # Asserting for specific patterns
          enterprise_cmd = described_class.provisioner_enterprise_cmd(node)
          expect(enterprise_cmd =~ /sudo -E provisioner-ctl/).not_to be nil
          expect(enterprise_cmd =~ /create-enterprise chefspec/).not_to be nil
          expect(enterprise_cmd =~ /--ssh-pub-key-file=/).not_to be nil
          expect(enterprise_cmd =~ %r{\/etc\/provisioner\/builder_key.pub}).not_to be nil
          expect(enterprise_cmd =~ %r{\/tmp\/chefspec.creds}).not_to be nil
        end
      end

      context 'is < 0.2.52' do
        before { node.default['server-provisioning']['provisioner']['version'] = '0.2.50' }

        it 'return the provisioner-ctl command to create an enterprise WITHOUT --ssh-pub-key-file' do
          # Asserting for specific patterns
          enterprise_cmd = described_class.provisioner_enterprise_cmd(node)
          expect(enterprise_cmd =~ /sudo -E provisioner-ctl/).not_to be nil
          expect(enterprise_cmd =~ /create-enterprise chefspec/).not_to be nil
          expect(enterprise_cmd =~ /--ssh-pub-key-file=/).to be nil
          expect(enterprise_cmd =~ %r{\/etc\/provisioner\/builder_key.pub}).to be nil
          expect(enterprise_cmd =~ %r{\/tmp\/chefspec.creds}).not_to be nil
        end
      end
    end

    context 'and the user is NOT root' do
      it 'return the provisioner_ctl command with sudo' do
        expect(described_class.provisioner_ctl(node)).to eq 'sudo -E provisioner-ctl'
      end
    end

    context 'and the user is root' do
      before do
        node.default['server-provisioning']['ssh']['ssh_username'] = 'root'
        Server::Helpers.instance_variable_set :@provisioning, nil
      end
      it 'return the provisioner_ctl command without sudo' do
        expect(described_class.provisioner_ctl(node)).to eq 'provisioner-ctl'
      end
    end
  end

  context 'when provisioner attributes are not set' do
    before { node.default['server-provisioning']['provisioner'] = nil }

    it 'raise an error' do
      expect { described_class.provisioner_server_hostname(node) }.to raise_error(RuntimeError)
    end
  end

  context 'when extra provisioner attributes are specified' do
    before { node.default['server-provisioning']['provisioner']['attributes'] = extra_provisioner_attributes }

    it 'returns extra provisioner attributes deep merged' do
      attr_rendered = described_class.provisioner_server_attributes(node)
      expect(attr_rendered.key(%w(super cool))).to eq('passed-something')
      expect(attr_rendered.key('carambola')).to eq('a-custom-attribute')
      expect(attr_rendered.key(1234)).to eq('port-for-something')
    end
  end
end
