require 'spec_helper'

describe "it should create a security group named 'test" do
  describe command('aws ec2 describe-security-groups --region us-west-2 --group-names test') do
    it {should_not return_exit_status 0}
    it {should return_stdout /'test' does not exist in default VPC/}
  end
end