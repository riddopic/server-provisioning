# encoding: UTF-8

name 'server-provisioning'
license 'Apache 2.0'
version '0.1.0'
maintainer 'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
description 'Provisioning cookbook for Chef infrastructure'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

if defined?(:source_url)
  source_url 'https://github.com/riddopic/provisioning'
end

if defined?(:issues_url)
  issues_url 'https://github.com/riddopic/provisioning/issues'
end

depends 'chef-server-12'
depends 'chef-ingredient'
depends 'git'
depends 'apt'
depends 'yum'
