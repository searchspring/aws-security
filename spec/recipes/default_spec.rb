require_relative '../spec_helper'

describe 'aws_security::default' do
    before do
    end
    subject { 
      runner = ChefSpec::Runner.new
      runner.node.set['memory']['total'] = '1696516kb'
      runner.node.set['lsb']['codename'] = 'rhel'
      runner.node.set['name'] = "rspec"
      runner.converge(described_recipe) 
    }
    it { should include_recipe "build-essential" }
    it { should install_chef_gem "fog"}
end
