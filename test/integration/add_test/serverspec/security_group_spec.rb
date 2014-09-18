require 'spec_helper'

describe "it should create a security group named 'test" do
  output = command('aws ec2 describe-security-groups --region us-west-2 --group-names test').stdout
  json = JSON.parse(output)
  sg = json["SecurityGroups"].first
  describe Hash do
  	subject {sg}
  	it { should include("GroupName" => "test")}
  	it { should include("Description"=>"test security group")}
  end
  ip_perms = sg['IpPermissions']
  ownerid = sg['OwnerId']
  describe ip_perms do
  	it { should include( {
  		                   "ToPort"=>80,
  		                   "IpProtocol"=>"tcp",
  		                   "IpRanges"=>[],
  		                   "UserIdGroupPairs"=>[{"UserId"=> ownerid, "GroupId"=>"sg-9b1a8ffe"}],
  		                   "FromPort"=>80}
    )}
  	it { should include( {
  		                   "ToPort"=>65535,
  		                   "IpProtocol"=>"tcp",
  		                   "IpRanges"=>[],
  		                   "UserIdGroupPairs"=>[{"UserId"=> ownerid, "GroupId"=>"sg-9b1a8ffe"}],
  		                   "FromPort"=>0
  		                 }
   	 )}
  	it { should include( {
  						   "ToPort"=>80, "IpProtocol"=>"tcp", "IpRanges"=>[
                             {"CidrIp"=>"192.168.1.1/32"}, 
                             {"CidrIp"=>"192.168.1.3/32"}
                           ],
  	                       "UserIdGroupPairs"=>[],
  	                       "FromPort"=>80
  	                     }
  	)}
  	it { should include({
  	                      "IpProtocol"=>"-1", 
  	                      "IpRanges"=>[{"CidrIp"=>"192.168.1.3/32"}],
  	                      "UserIdGroupPairs"=>[]
  	                    }
  	)}
  	it { should include({
  	                      "ToPort"=>80,
  	                      "IpProtocol"=>"udp",
  	                      "IpRanges"=>[{"CidrIp"=>"192.168.1.2/32"}],
  	                      "UserIdGroupPairs"=>[], "FromPort"=>80
  	                    }
  	)}
  end
end