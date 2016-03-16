# encoding: UTF-8

require 'spec_helper'

describe Server::Helpers do
  let(:node) { Chef::Node.new }

  before do
    node.default['provisioning'] = cluster_data
    allow_any_instance_of(Chef::Node).to receive(:save).and_return(true)
    allow(Server::Helpers).to receive(:node).and_return(node)
    allow(Chef::Node).to receive(:load).and_return(Chef::Node.new)
    allow(Chef::ServerAPI).to receive(:new).and_return(rest)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/supermarket-server-chefspec')
      .and_return(supermarket_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/analytics-server-chefspec')
      .and_return(analytics_node)
  end

  it 'return the cluster_id' do
    expect(described_class.chef_provisioning_id(node)).to eq 'chefspec'
  end

  it 'return false if provisioning_data_dir is not a link' do
    expect(described_class.provisioning_data_dir_link?).to eq false
  end

  it 'return the provisioning_data_dir' do
    expect(described_class.provisioning_data_dir(node)).to eq File.join(Chef::Config.chef_repo_path, '.chef', 'provisioning-data-chefspec')
  end

  it 'return the current_dir that is the chef_repo_path' do
    expect(described_class.current_dir).to eq Chef::Config.chef_repo_path
  end

  context 'when cluster_id' do
    context 'is specified' do
      it 'return the chef_provisioning_id' do
        expect(described_class.chef_provisioning_id(node)).to eq 'chefspec'
      end
    end
    context 'is NOT specified' do
      before { node.default['provisioning']['id'] = nil }

      it 'create a chef_provisioning_id and return it' do
        expect(described_class.chef_provisioning_id(node)).not_to be nil
        expect(described_class.chef_provisioning_id(node).class).to be String
      end
    end
  end

  context 'when driver' do
    context 'SSH is specified' do
      before do
        node.default['provisioning']['driver'] = 'ssh'
        node.default['provisioning']['ssh'] = ssh_data
        Server::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq nil
      end

      it 'return the username' do
        expect(described_class.username(node)).to eq 'ubuntu'
      end

      it 'return the ip address' do
        expect(described_class.get_ip(node, chef_node)).to eq '10.1.1.1'
      end

      it 'return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq Server::Provisioning::Ssh
      end
    end

    context 'AWS is specified' do
      before do
        node.default['provisioning']['driver'] = 'aws'
        node.default['provisioning']['aws'] = aws_data
        Server::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq true
      end

      it 'return the username' do
        expect(described_class.username(node)).to eq 'ubuntu'
      end

      it 'return the ip address' do
        expect(described_class.get_ip(node, supermarket_node)).to eq '10.1.1.3'
      end

      it 'return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq Server::Provisioning::Aws
      end
    end

    context 'VAGRANT is specified' do
      before do
        node.default['provisioning']['driver'] = 'vagrant'
        node.default['provisioning']['vagrant'] = vagrant_data
        Server::Helpers.instance_variable_set :@provisioning, nil
      end

      it 'use_private_ip_for_ssh return ' do
        expect(described_class.use_private_ip_for_ssh(node)).to eq false
      end

      it 'return the username' do
        expect(described_class.username(node)).to eq 'vagrant'
      end

      it 'return the ip address' do
        expect(described_class.get_ip(node, provisioner_node)).to eq '10.1.1.2'
      end

      it 'return the provisioning instance' do
        expect(described_class.provisioning(node).class).to eq Server::Provisioning::Vagrant
      end
    end

    context 'is NOT specified' do
      it 'raise an error trying to access use_private_ip_for_ssh' do
        expect { described_class.use_private_ip_for_ssh(node) }.to raise_error(RuntimeError)
      end

      it 'raise an error trying to access username' do
        expect { described_class.username(node) }.to raise_error(RuntimeError)
      end

      it 'raise an error trying to access get_ip' do
        expect { described_class.get_ip(node, analytics_node) }.to raise_error(RuntimeError)
      end

      it 'raise an error trying to access provisioning' do
        expect { described_class.provisioning(node) }.to raise_error(RuntimeError)
      end
    end
  end

  it 'return return knife variables' do
    expect(described_class.knife_variables(node)).to eq(
      chef_server_url: 'https://chef-server.chef.io/organizations/chefspec',
      client_key: File.join(Chef::Config.chef_repo_path, '.chef', 'provisioning-data-chefspec', 'provisioner.pem'),
      analytics_server_url: '',
      supermarket_site: ''
    )
  end
end
