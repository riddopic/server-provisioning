# encoding: UTF-8

require 'spec_helper'

describe Server::Helpers::Component do
  let(:node) { Chef::Node.new }
  before do
    node.default['server-provisioning'] = cluster_data
    allow(Chef::Node).to receive(:load).and_return(Chef::Node.new)
    allow(Chef::ServerAPI).to receive(:new).and_return(rest)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/chef-server-chefspec')
      .and_return(chef_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/provisioner-server-chefspec')
      .and_return(provisioner_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/supermarket-server-chefspec')
      .and_return(supermarket_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/analytics-server-chefspec')
      .and_return(analytics_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/splunk-server-chefspec')
      .and_return(splunk_node)
  end

  context 'when fqdn' do
    context 'is speficied' do
      it 'return chef-server component fqdn' do
        expect(described_class.component_fqdn(node, 'chef-server')).to eq cluster_data['chef-server']['fqdn']
      end

      it 'return provisioner component fqdn' do
        expect(described_class.component_fqdn(node, 'provisioner')).to eq cluster_data['provisioner']['fqdn']
      end

      it 'return supermarket component fqdn' do
        expect(described_class.component_fqdn(node, 'supermarket')).to eq cluster_data['supermarket']['fqdn']
      end

      it 'return analytics component fqdn' do
        expect(described_class.component_fqdn(node, 'analytics')).to eq cluster_data['analytics']['fqdn']
      end

      it 'return splunk component fqdn' do
        expect(described_class.component_fqdn(node, 'splunk')).to eq cluster_data['splunk']['fqdn']
      end
    end

    context 'is NOT speficied and host' do
      before do
        node.default['server-provisioning']['chef-server']['fqdn'] = nil
        node.default['server-provisioning']['provisioner']['fqdn']    = nil
        node.default['server-provisioning']['supermarket']['fqdn'] = nil
        node.default['server-provisioning']['analytics']['fqdn']   = nil
        node.default['server-provisioning']['splunk']['fqdn']      = nil
      end

      context 'does exist' do
        it 'return chef-server component host' do
          expect(described_class.component_fqdn(node, 'chef-server')).to eq cluster_data['chef-server']['host']
        end

        it 'return provisioner component host' do
          expect(described_class.component_fqdn(node, 'provisioner')).to eq cluster_data['provisioner']['host']
        end

        it 'return supermarket component host' do
          expect(described_class.component_fqdn(node, 'supermarket')).to eq cluster_data['supermarket']['host']
        end

        it 'return analytics component host' do
          expect(described_class.component_fqdn(node, 'analytics')).to eq cluster_data['analytics']['host']
        end

        it 'return splunk component host' do
          expect(described_class.component_fqdn(node, 'splunk')).to eq cluster_data['splunk']['host']
        end
      end

      context 'does NOT exist' do
        before do
          node.default['server-provisioning']['chef-server']['host'] = nil
          node.default['server-provisioning']['provisioner']['host']    = nil
          node.default['server-provisioning']['supermarket']['host'] = nil
          node.default['server-provisioning']['analytics']['host']   = nil
          node.default['server-provisioning']['splunk']['host']      = nil
          node.default['server-provisioning']['driver'] = 'ssh'
          node.default['server-provisioning']['ssh'] = ssh_data
        end

        it 'return chef-server component ip_address' do
          expect(described_class.component_fqdn(node, 'chef-server')).to eq '10.1.1.1'
        end

        it 'return provisioner component ip_address' do
          expect(described_class.component_fqdn(node, 'provisioner')).to eq '10.1.1.2'
        end

        it 'return supermarket component ip_address' do
          expect(described_class.component_fqdn(node, 'supermarket')).to eq '10.1.1.3'
        end

        it 'return analytics component ip_address' do
          expect(described_class.component_fqdn(node, 'analytics')).to eq '10.1.1.4'
        end

        it 'return splunk component ip_address' do
          expect(described_class.component_fqdn(node, 'splunk')).to eq '10.1.1.5'
        end
      end
    end
  end

  context 'when `hostname` attribute' do
    context 'is NOT configured' do
      %w( provisioner supermarket analytics splunk ).each do |component|
        it "generate a hostname for #{component}" do
          expect(described_class.component_hostname(node, component)).to eq "#{component}-server-chefspec"
        end
      end

      it 'generate a hostname for chef-server' do
        expect(described_class.component_hostname(node, 'chef-server')).to eq 'chef-server-chefspec'
      end
    end

    context 'is configured' do
      before do
        node.default['server-provisioning']['chef-server']['hostname'] = 'my-cool-hostname.chef-server.com'
        node.default['server-provisioning']['provisioner']['hostname']    = 'my-cool-hostname.provisioner.com'
        node.default['server-provisioning']['supermarket']['hostname'] = 'my-cool-hostname.supermarket.com'
        node.default['server-provisioning']['analytics']['hostname']   = 'my-cool-hostname.analytics.com'
        node.default['server-provisioning']['splunk']['hostname']      = 'my-cool-hostname.splunk.com'
      end

      %w( chef-server provisioner supermarket analytics splunk ).each do |component|
        it "return our cool-#{component} hostname" do
          expect(described_class.component_hostname(node, component)).to eq "my-cool-hostname.#{component}.com"
        end
      end
    end
  end

  it 'return the hostname for multiple machines' do
    1.upto(cluster_data['builders']['count'].to_i) do |index|
      expect(described_class.component_hostname(node, 'builders', index.to_s)).to eq "build-node-chefspec-#{index}"
    end
  end

  context 'when the component attributes are not set' do
    before do
      node.default['server-provisioning']['chef-server']  = nil
      node.default['server-provisioning']['provisioner']     = nil
      node.default['server-provisioning']['supermarket']  = nil
      node.default['server-provisioning']['analytics']    = nil
      node.default['server-provisioning']['splunk']       = nil
      node.default['server-provisioning']['builders']     = nil
    end

    %w( chef-server provisioner supermarket analytics splunk builders ).each do |component|
      it "raise an error for #{component}" do
        expect { described_class.component_hostname(node, component) }.to raise_error(RuntimeError)
      end
    end

    it 'raise an error when you try to access a multiple_component_hostname' do
      expect { described_class.component_hostname(node, 'machines', '1') }.to raise_error(RuntimeError)
    end
  end
end
