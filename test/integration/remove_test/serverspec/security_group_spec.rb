require 'spec_helper'

describe "it should create a security group named 'test" do
  describe ec2.security_groups.all('group-name' => 'test') do
    it { should eq [] }
  end
end
