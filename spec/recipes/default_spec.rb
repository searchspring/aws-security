require_relative '../spec_helper'

describe 'aws_security::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end

end
