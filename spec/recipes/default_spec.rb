require_relative '../spec_helper'

describe 'aws_security::default' do
    before do
    end
    subject { 
      runner = ChefSpec::SoloRunner.new
      runner.node.set['memory']['total'] = '1696516kb'
      runner.node.set['lsb']['codename'] = 'rhel'
      runner.node.set['name'] = "rspec"
      runner.converge(described_recipe) 
    }
    it { should include_recipe "fog_gem::chefgem" }
end
