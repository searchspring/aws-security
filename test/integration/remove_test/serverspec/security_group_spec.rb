require 'spec_helper'

describe "it should create a security group named 'test" do
  describe command('aws ec2 describe-security-groups --region us-west-2 --group-names test') do
    its(:exit_status) { should_not eq 0}
    its(:stdout) { should match(/'test' does not exist in default VPC/)}
  end
end
