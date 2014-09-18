# Added by ChefSpec
require 'chefspec'
require 'chefspec/berkshelf'
# require 'chefspec/server'
require_relative '../libraries/ec2'

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks
  # config.cookbook_path = '/var/cookbooks'

  # Specify the path for Chef Solo to find roles
  # config.role_path = '/var/roles'

  # Specify the Chef log_level (default: :warn)
  config.log_level = :warn

  # Specify the path to a local JSON file with Ohai data
  # config.path = 'ohai.json'

  # Specify the operating platform to mock Ohai data from
  config.platform = 'amazon'

  # Specify the operating version to mock Ohai data from
  config.version = '2012.09'

  # :focus support to allow zooming in a single test/block
  # config.filter_run :focus => true
  # config.run_all_when_everything_filtered = true
  # config.treat_symbols_as_metadata_keys_with_true_values = true
end
