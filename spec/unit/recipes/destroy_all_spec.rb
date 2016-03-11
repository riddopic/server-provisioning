# encoding: UTF-8

require 'spec_helper'

describe 'server-provisioning::destroy_all' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['server-provisioning'] = cluster_data
    end
  end

  context 'always' do
    before do
      allow(Server::Helpers).to receive(:is_provisioning_data_dir_link?)
        .and_return(true)
      chef_run.converge(described_recipe)
    end

    includes = %w(
      _settings destroy_builders destroy_analytics destroy_supermarket
      destroy_splunk destroy_provisioner destroy_chef_server destroy_cluster_data
    )

    includes.each do |recipename|
      it "includes #{recipename} recipe" do
        expect(chef_run).to include_recipe("server-provisioning::#{recipename}")
      end
    end
  end
end
