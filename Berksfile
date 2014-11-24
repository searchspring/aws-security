source "https://api.berkshelf.com"

metadata

cookbook 'build-essential', '~> 2.0.6'
cookbook 'fog_gem', '~> 0.1.1'
cookbook 'nokogiri', '~> 0.1.1'
cookbook 'libxml2', '~> 0.1.1'

group :integration do
  cookbook 'fake', path: 'test/fixtures/cookbooks/fake'
  cookbook 'python'
end
