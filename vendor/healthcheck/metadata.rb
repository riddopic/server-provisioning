# encoding: UTF-8

name 'healthcheck'
license 'Apache 2.0'
version '0.1.0'
maintainer 'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
description 'Installs/Configures healthcheck'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
supports 'ubuntu', '14.04'

if respond_to?(:source_url)
  source_url 'https://github.com/riddopic/provisioning'
end

if respond_to?(:issues_url)
  issues_url 'https://github.com/riddopic/provisioning/issues'
end

depends 'apt'
depends 'openssh'
depends 'ntp'
depends 'git'
depends 'user'
depends 'docker'
