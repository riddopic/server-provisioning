# encoding: UTF-8

require 'spec_helper'

describe 'server-provisioning::setup' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:activate_supermarket).and_return(true)
  end

  describe '#vagrant driver' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['server-provisioning'] = cluster_data
        node.set['server-provisioning']['driver'] = 'vagrant'
        node.set['server-provisioning']['vagrant'] = vagrant_data
      end
    end

    before do
      Server::Helpers.instance_variable_set :@provisioning, nil
      chef_run.converge(described_recipe)
    end

    context 'always' do
      includes = %w( _settings setup_chef_server setup_provisioner)
      includes.each do |recipename|
        it "includes #{recipename} recipe" do
          expect(chef_run)
            .to include_recipe("server-provisioning::#{recipename}")
        end
      end
    end

    context 'build-nodes without specs' do
      before do
        chef_run.node.set['server-provisioning']['builders']['count'] = '99'
        chef_run.converge(described_recipe)
      end

      it 'converges successfully by rendering the attributes' do
        expect { chef_run }.to_not raise_error(RuntimeError)
        expect(chef_run.node['server-provisioning']['builders']['99']).to eq(
          'hostname' => 'build-node-chefspec-99'
        )
      end
    end

    context 'when supermarket is enabled' do
      it 'includes supermarket recipe' do
        expect(chef_run)
          .to include_recipe('server-provisioning::setup_supermarket')
      end
    end

    context 'when supermarket is disabled' do
      before do
        chef_run.node.set['server-provisioning']['supermarket'] = nil
        chef_run.converge(described_recipe)
      end
      it 'does not includes supermarket recipe' do
        expect(chef_run)
          .to_not include_recipe('server-provisioning::setup_supermarket')
      end
    end
  end

  describe '#aws driver' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['server-provisioning'] = cluster_data
        node.set['server-provisioning']['driver'] = 'aws'
        node.set['server-provisioning']['aws'] = aws_data
      end
    end

    context 'always' do
      before do
        Server::Helpers.instance_variable_set :@provisioning, nil
        chef_run.converge(described_recipe)
      end

      includes = %w(_settings setup_chef_server setup_provisioner)

      includes.each do |recipename|
        it "includes #{recipename} recipe" do
          expect(chef_run)
            .to include_recipe("server-provisioning::#{recipename}")
        end
      end
    end
  end

  describe '#ssh driver' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['server-provisioning'] = cluster_data
        node.set['server-provisioning']['driver'] = 'ssh'
        node.set['server-provisioning']['ssh'] = ssh_data
      end
    end

    context 'always' do
      before do
        Server::Helpers.instance_variable_set :@provisioning, nil
        chef_run.converge(described_recipe)
      end

      includes = %w( _settings setup_chef_server setup_provisioner)

      includes.each do |recipename|
        it "includes #{recipename} recipe" do
          expect(chef_run)
            .to include_recipe("server-provisioning::#{recipename}")
        end
      end
    end
  end
end
