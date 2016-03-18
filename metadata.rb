# encoding: UTF-8

name 'provisioning'
license 'Apache 2.0'
version '0.1.0'
maintainer 'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
description 'Provisioning cookbook for Chef infrastructure'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

if respond_to?(:source_url)
  source_url 'https://github.com/riddopic/provisioning'
end

if respond_to?(:issues_url)
  issues_url 'https://github.com/riddopic/provisioning/issues'
end

depends 'chef-server-12'
depends 'chef-ingredient', '= 0.16.0'
depends 'jenkins', '~> 2.4'
depends 'healthcheck'
depends 'git'
depends 'apt'
depends 'yum'
