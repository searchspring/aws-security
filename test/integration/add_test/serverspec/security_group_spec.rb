require 'spec_helper'

describe "it should create a security group named 'test" do
  sg              = ec2.security_groups.all('group-name' => 'test').first

  describe sg.attributes do
    it { should include(name: "test") }
    it { should include(description: "test security group") }
  end
  describe sg.ip_permissions do
    it { should include("toPort"     => 80,
                        "ipProtocol" => "tcp",
                        "ipRanges"   => [],
                        "groups"     => [{"userId"  =>  sg[:owner_id],
                                          "groupId" => "sg-9b1a8ffe"}],
                        "fromPort"   => 80)
    }
    it { should include("toPort"     => 65535,
                        "ipProtocol" => "tcp",
                        "ipRanges"   => [],
                        "groups"     => [{"userId"  =>  sg[:owner_id],
                                          "groupId" => "sg-9b1a8ffe"}],
                        "fromPort"   => 0)
    }
    it { should include("toPort"     => 80,
                        "ipProtocol" => "tcp",
                        "ipRanges"   => [{"cidrIp" => "192.168.1.1/32"}, 
                                         {"cidrIp" => "192.168.1.3/32"}],
                         "groups"    => [],
                         "fromPort"  => 80)
    }
    it { should include("ipProtocol" => "-1", 
                        "ipRanges"   => [{"cidrIp" => "192.168.1.3/32"}],
                        "groups"     => [])
    }
    it { should include("toPort"     => 80,
                        "ipProtocol" => "udp",
                        "ipRanges"   => [{"cidrIp" => "192.168.1.2/32"}],
                        "groups"     => [],
                        "fromPort"   => 80)
    }
  end
end
