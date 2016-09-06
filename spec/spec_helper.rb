require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify the Chef log_level (default: :warn)
  config.log_level = :fatal

  # Specify the operating platform to mock Ohai data from
  config.platform = 'amazon'

  # Specify the operating version to mock Ohai data from
  config.version = '2016.03'
end
