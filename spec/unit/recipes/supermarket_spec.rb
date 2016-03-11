# encoding: UTF-8

require 'spec_helper'

describe 'server-provisioning::supermarket' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['server-provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  before do
    allow(JSON).to receive(:pretty_generate).and_return('config')
    stub_command('grep Fauxhai /etc/hosts').and_return(true)
  end

  it 'adds supermarket ingredient config' do
    expect(chef_run).to add_ingredient_config('supermarket')
  end

  it 'installs and reconfigures supermarket ingredient' do
    expect(chef_run).to install_chef_ingredient('supermarket')
    expect(chef_run).to reconfigure_chef_ingredient('supermarket')
  end
end
