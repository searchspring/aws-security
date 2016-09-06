require 'spec_helper'

describe "it should create a security group named 'test" do
  sg              = ec2.security_groups.all('group-name' => 'test').first
  source_group_id = ec2.security_groups.all(
    'group-name' => 'test_source_group'
  ).first.group_id
  user_id = '111122223333'

  describe sg.attributes do
    it { should include(name: 'test') }
    it { should include(description: 'test security group') }
  end
  describe sg.ip_permissions do
    it { should have_exactly(5).entries }
    it do
      should include('fromPort'   => 80,
                     'toPort'     => 80,
                     'ipProtocol' => 'tcp',
                     'ipRanges'   => [{ 'cidrIp' => '192.168.1.1/32' }],
                     'groups' => [])
    end
    it do
      should include('fromPort'   => 80,
                     'toPort'     => 80,
                     'ipProtocol' => 'udp',
                     'ipRanges'   => [{ 'cidrIp' => '192.168.1.2/32' }],
                     'groups'     => [])
    end
    it do
      should include('fromPort'   => 80,
                     'toPort'     => 80,
                     'ipProtocol' => 'tcp',
                     'ipRanges'   => [{ 'cidrIp' => '192.168.1.3/32' }],
                     'groups' => [])
    end
    it do
      should include('fromPort'   => 80,
                     'toPort'     => 80,
                     'ipProtocol' => 'tcp',
                     'ipRanges'   => [],
                     'groups'     => [{ 'userId' => user_id,
                                        'groupName' => 'test_source_group',
                                        'groupId'   => source_group_id }])
    end
    it do
      should include('fromPort'   => 0,
                     'toPort'     => 65_535,
                     'ipProtocol' => 'tcp',
                     'ipRanges'   => [],
                     'groups'     => [{ 'userId' => user_id,
                                        'groupName' => 'test_source_group',
                                        'groupId'   => source_group_id }])
    end
  end
end
