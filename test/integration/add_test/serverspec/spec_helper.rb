require 'serverspec'
require 'rspec/collection_matchers'
require 'fog-aws'

set :backend, :exec

def ec2
  @ec2 ||= Fog::Compute::AWS.new(host: 'localhost',
                                 port: 5000,
                                 scheme: 'http',
                                 aws_access_key_id: 'MOCKING',
                                 aws_secret_access_key: 'MOCKING')
end
