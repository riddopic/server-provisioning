# encoding: UTF-8

name 'chef-server-12'
license 'Apache 2.0'
version '0.1.0'
maintainer 'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
description 'Provisioning cookbook for Chef Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

depends 'chef-ingredient'
depends 'hostsfile'

supports 'ubuntu'
supports 'centos'
supports 'redhat'
