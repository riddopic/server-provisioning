# encoding: UTF-8

include_recipe 'provisioning::_settings'

aws_security_group 'ref-sg1' do
  inbound_rules [
    { port: 22,           protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 80,           protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 443,          protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 8989,         protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 5672,         protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 10000..10003, protocol: :tcp, sources: ['24.7.32.100/32'] },
    { port: 10012..10013, protocol: :tcp, sources: ['24.7.32.100/32'] }
  ]
  outbound_rules [
    { port: 0..65535, destinations: ['0.0.0.0/0'] }
  ]
  vpc 'default'
  aws_tags generate_tags('aws_security_group')
end
