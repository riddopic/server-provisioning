#
# Cookbook Name:: provisioner-cluster
# Spec:: setup_provisioner_server_spec
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe 'server-provisioning::setup_provisioner_server' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['server-provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  before do
    allow_any_instance_of(Chef::Resource).to receive(:provisioning_data_dir)
      .and_return('/repo/provisioner-cluster-dir')
  end

  it 'includes _settings recipe' do
    expect(chef_run).to include_recipe('server-provisioning::_settings')
  end

  it 'converge provisioner machine' do
    expect(chef_run).to converge_machine('provisioner-server-chefspec')
      .with_files(
        '/etc/provisioner/provisioner.pem' => '/repo/provisioner-cluster-dir/provisioner.pem',
        '/etc/provisioner/builder_key' => '/repo/provisioner-cluster-dir/builder_key',
        '/etc/provisioner/builder_key.pub' => '/repo/provisioner-cluster-dir/builder_key.pub'
      )
  end

  it 'download the credentials chefspec.creds' do
    expect(chef_run).to download_machine_file('/tmp/chefspec.creds')
      .with_machine('provisioner-server-chefspec')
  end

  it 'download provisioner-server-cert' do
    expect(chef_run).to download_machine_file('provisioner-server-cert')
      .with_machine('provisioner-server-chefspec')
  end

  it 'create an enterprise' do
    expect(chef_run).to run_machine_execute('Creating Enterprise')
      .with_machine('provisioner-server-chefspec')
  end
end