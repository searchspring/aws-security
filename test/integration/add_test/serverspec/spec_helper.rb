require 'serverspec'
require 'json'
require 'fog'

set :backend, :exec

RSpec.configure do |c|  
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask("Enter sudo password: ") { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end
end  

def ec2
  @ec2 ||= Fog::Compute::AWS.new(host: 'localhost', port: 5000, scheme: 'http')
end
