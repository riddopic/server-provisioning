# encoding: UTF-8

require 'spec_helper'

describe 'server-provisioning::pkg_repo_management' do
  context 'debian systems' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        log_level: :error
      )
      runner.converge(described_recipe)
    end

    it 'include apt cookbook' do
      expect(chef_run).to include_recipe 'apt'
    end

    it 'NOT include yum cookbook' do
      expect(chef_run).to_not include_recipe 'yum'
    end
  end

  context 'rhel systems' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'redhat',
        version: '6.5',
        log_level: :error
      )
      runner.converge(described_recipe)
    end

    it 'include yum cookbook' do
      expect(chef_run).to include_recipe 'yum'
    end

    it 'NOT include apt cookbook' do
      expect(chef_run).to_not include_recipe 'apt'
    end

    it 'clean cache at compile time' do
      expect(chef_run).to run_execute('yum clean all').at_compile_time
    end
  end

  context 'windows systems' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'windows',
        version: '2008R2',
        log_level: :error
      )
      runner.converge(described_recipe)
    end

    before do
      # Mocking Windows Environment Variables that `omnibus` cookbook use
      ENV['SYSTEMDRIVE'] = 'C:'
      ENV['USERPROFILE'] = 'C:/Users'
    end

    it 'NOT include yum cookbook' do
      expect(chef_run).to_not include_recipe 'yum'
    end

    it 'NOT include apt cookbook' do
      expect(chef_run).to_not include_recipe 'apt'
    end

    it 'write log' do
      expect(chef_run)
        .to write_log 'provisioner-cluster-pkg-repo-update-not-handled'
    end
  end
end
