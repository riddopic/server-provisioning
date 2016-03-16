# encoding: UTF-8

require 'spec_helper'

describe 'provisioning::analytics' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  it 'adds analytics ingredient config' do
    expect(chef_run).to add_ingredient_config('analytics')
  end

  it 'installs and reconfigures analytics ingredient' do
    expect(chef_run).to install_chef_ingredient('analytics')
    expect(chef_run).to reconfigure_chef_ingredient('analytics')
  end
end
