# encoding: UTF-8

source 'https://supermarket.chef.io'

metadata

cookbook 'chef-server-12',
  path: 'vendor/chef-server-12'

cookbook 'healthcheck',
  path: 'vendor/healthcheck'

cookbook 'hostsfile'

# Point to this repo until this PR is merged:
# https://github.com/hw-cookbooks/runit/pull/164
cookbook 'runit',
  git: 'https://github.com/afiune/runit.git',
  branch: 'afiune/make-it-work-in-oel'
