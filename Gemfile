source 'https://rubygems.org'

gem 'fog-aws', '~> 0.11'

group :lint do
  gem 'foodcritic', '~> 7.0'
  gem 'cookstyle'
end

group :unit do
  gem 'berkshelf',  '~> 4.3'
  gem 'chefspec',   '~> 4.7'
  gem 'rspec_junit_formatter', '~> 0.1'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.11'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.20'
end
