# encoding: UTF-8

require 'spec_helper'

describe Server::Helpers::ChefServer do
  let(:node) { Chef::Node.new }
  let(:provisioning_password) { 'SuperSecurePassword' }
  let(:extra_chef_server_attributes) do
    {
      'passed-something' => %w(super cool),
      'a-custom-attribute' => 'carambola',
      'port-for-something' => 1234
    }
  end
  let(:mock_chef_server_attributes) do
    {
      'provisioner' => {
        'organization' => 'chefspec',
        'password' => provisioning_password
      },
      'api_fqdn' => 'chef-server.chef.io',
      'store_keys_databag' => false,
      'plugin' => {
        'reporting' => true
      }
    }
  end
  let(:mock_analytics_server_attributes) do
    {
      'analytics' => {
        'fqdn' => 'analytics-server.chef.io'
      }
    }
  end
  let(:mock_supermarket_server_attributes) do
    {
      'supermarket' => {
        'fqdn' => 'supermarket-server.chef.io'
      }
    }
  end

  before do
    node.default['provisioning'] = cluster_data
    node.default['provisioning']['chef-server']['enable-reporting'] = true
    allow(Chef::Node).to receive(:load).and_return(Chef::Node.new)
    allow(Chef::ServerAPI).to receive(:new).and_return(rest)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/supermarket-server-chefspec')
      .and_return(supermarket_node)
    allow_any_instance_of(Chef::ServerAPI).to receive(:get)
      .with('nodes/analytics-server-chefspec')
      .and_return(analytics_node)
  end

  it 'returns chef-server hostname for a machine resource' do
    expect(described_class.chef_server_hostname(node)).to eq 'chef-server-chefspec'
  end

  it 'returns chef-server fqdn' do
    expect(described_class.chef_server_fqdn(node)).to eq 'chef-server.chef.io'
  end

  it 'returns chef-server fqdn' do
    expect(described_class.chef_server_fqdn(node)).to eq 'chef-server.chef.io'
  end

  it 'returns a random provisioner password' do
    random_password = described_class.provisioning_password(node)
    expect(described_class.provisioning_password(node)).to_not eq provisioning_password
    expect(described_class.provisioning_password(node)).to eq random_password
  end

  it 'return the chef-server configuration for a machine resource' do
    expect(described_class.chef_server_config(node)).to eq(
      chef_server_url: 'https://chef-server.chef.io/organizations/chefspec',
      options: {
        client_name: 'provisioner',
        signing_key_filename: File.join(Chef::Config.chef_repo_path, '.chef', 'provisioning-data-chefspec', 'provisioner.pem')
      }
    )
  end

  context 'with same provisioner password' do
    # Mock the provisioner passsword to test other attributes
    before do
      allow(Server::Helpers::ChefServer).to receive(:provisioning_password)
        .and_return(provisioning_password)
    end

    context 'when there is neither supermarket server nor analytics server' do
      it 'return just the chef-server attributes' do
        expect(described_class.chef_server_attributes(node)).to eq('chef-server-12' => mock_chef_server_attributes)
      end
    end

    context 'when there is a supermarket server' do
      before do
        allow(Server::Helpers::Supermarket).to receive(:supermarket_enabled?).and_return(true)
      end

      it 'return the chef-server attributes plus supermarket attributes' do
        expect(described_class.chef_server_attributes(node)).to eq(
          'chef-server-12' => mock_chef_server_attributes.merge(mock_supermarket_server_attributes)
        )
      end
    end

    context 'when there is a analytics server' do
      before do
        allow(Server::Helpers::Analytics).to receive(:analytics_enabled?).and_return(true)
      end

      it 'return the chef-server attributes plus analytics attributes' do
        expect(described_class.chef_server_attributes(node)).to eq(
          'chef-server-12' => mock_chef_server_attributes.merge(mock_analytics_server_attributes)
        )
      end

      context 'AND a supermarket server (both)' do
        before do
          allow(Server::Helpers::Supermarket).to receive(:supermarket_enabled?).and_return(true)
        end

        it 'return the chef-server attributes plus supermarket attributes plus analytics attributes' do
          expect(described_class.chef_server_attributes(node)).to eq(
            'chef-server-12' => mock_chef_server_attributes
              .merge(mock_supermarket_server_attributes)
              .merge(mock_analytics_server_attributes)
          )
        end

        context 'plus extra attributes that the user specified' do
          before do
            node.default['provisioning']['chef-server']['attributes'] = extra_chef_server_attributes
          end

          it 'returns all of them plus the extra attributes' do
            expect(described_class.chef_server_attributes(node)).to eq(
              extra_chef_server_attributes.merge(
                'chef-server-12' => mock_chef_server_attributes
                  .merge(mock_supermarket_server_attributes)
                  .merge(mock_analytics_server_attributes)
              )
            )
          end
        end
      end
    end
  end

  context 'when chef-server attributes are not set' do
    before { node.default['provisioning']['chef-server'] = nil }

    it 'raise an error' do
      expect { described_class.chef_server_hostname(node) }.to raise_error(RuntimeError)
    end
  end
end
