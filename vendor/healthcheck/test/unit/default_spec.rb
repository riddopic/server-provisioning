# encoding: UTF-8

require 'spec_helper'

describe 'healthcheck::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '14.04'
    )
  end

  before do
    # mock users -> ciuser databag
    ChefSpec::Server.create_data_bag('users',
      'ciuser' => {
        'id' => 'ciuser',
        'comment' => 'continuous integration user',
        'home' => '/home/ciuser',
        'ssh_keygen' => true
      }
    )
  end

  it 'should include all the healthcheck recipes by default' do
    chef_run.converge(described_recipe)
    expect(chef_run).to include_recipe('healthcheck::default')
    expect(chef_run).to include_recipe('healthcheck::common')
    expect(chef_run).to include_recipe('healthcheck::user')
    expect(chef_run).to include_recipe('healthcheck::docker')
  end

  it 'should not include healthcheck::monitoring recipe' do
    chef_run.node.set['monitoring']['enabled'] = false
    chef_run.converge(described_recipe)
    expect(chef_run).not_to include_recipe('healthcheck::monitoring')
  end

end
