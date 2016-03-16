# encoding: UTF-8

require 'spec_helper'

describe 'provisioning::setup_analytics' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  before do
    allow_any_instance_of(Chef::Recipe)
      .to receive(:activate_analytics).and_return(true)
    allow_any_instance_of(Chef::Recipe)
      .to receive(:provisioning_data_dir).and_return('/tmp')
  end

  it 'includes _settings recipe' do
    expect(chef_run).to include_recipe('provisioning::_settings')
  end

  it 'converge analytics machine' do
    expect(chef_run).to converge_machine('analytics-server-chefspec')
  end

  it 'converge chef-server machine' do
    expect(chef_run).to converge_machine('chef-server-chefspec')
  end

  %w( actions-source.json webui_priv.pem ).each do |analytics_file|
    it "download #{analytics_file}" do
      expect(chef_run)
        .to download_machine_file("/etc/opscode-analytics/#{analytics_file}")
        .with_machine('chef-server-chefspec')
    end
  end

  it 'download analytics-server-cert' do
    expect(chef_run).to download_machine_file('analytics-server-cert')
      .with_machine('analytics-server-chefspec')
  end

  it 'add analytics to the rendered knife.rb' do
    expect(chef_run).to create_template('/tmp/knife.rb')
  end
end
