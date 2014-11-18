include Aws::Ec2

def whyrun_supported?
  true
end

action :add do
  if @current_resource.exists
  	Chef::Log.info("#{ @new_resource } already exists -- nothing to do")
  else
  	fail "#{ new_reouce } can not be created -- security group does not " \
      'exist' unless security_group
	  converge_by("Adding rule #{ @new_resource } to security group") do
      from_port = @current_resource.from_port
      to_port = @current_resource.to_port
      security_group.authorize_port_range(from_port..to_port,
                                          construct_security_group_options)
    end
  end
end

action :remove do
  if @current_resource.exists
    converge_by("Removing rule #{ @new_resource } from security group") do
      from_port = @current_resource.from_port
      to_port = @current_resource.to_port
      security_group.revoke_port_range(from_port..to_port,
                                       construct_security_group_options)
    end
  else
    Chef::Log.info("#{ @new_resource } does not exists -- nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AwsSecurityGroupRule.new(@new_resource.name)

  @current_resource.aws_access_key_id(@new_resource.aws_access_key_id || node['aws_security']['aws_access_key_id'])
  @current_resource.aws_secret_access_key(@new_resource.aws_access_key_id || node['aws_security']['aws_secret_access_key'])

  %w(groupname
     name
     cidr_ip
     group
     ip_protocol
     port_range
     owner
     region).each do |attrib|
    @current_resource.send(attrib, @new_resource.send(attrib))
  end

  if @current_resource.port_range
    (from_port,to_port) = @current_resource.port_range.split(/\.\./)
    @current_resource.from_port(from_port.to_i)
    @current_resource.to_port(to_port.to_i)
  else
    @current_resource.from_port(@new_resource.from_port)
    @current_resource.to_port(@new_resource.to_port)
  end
  if new_resource.groupid
    @current_resource.groupid(@new_resource.groupid)
  elsif sg = security_groupname_exists? 
    @current_resource.groupid(sg.group_id)
  # else
    # fail "Could not find security groupid for #{ new_resource }"
  end
 if security_group_rule_exists?
    @current_resource.exists = true
  end 
end

def security_group_rule
  return false unless @current_resource.groupid
  # rule we're trying to create
  new_ip_permission = current_resource_ip_permissions
  # loop through existing rules looking for our new rule
  security_group.ip_permissions.each do |ip_permission|
  	# rules are either group based or ip based
  	group_or_ip = @current_resource.group ? "groups" : "ipRanges"
  	# if the protocol is '-1' then there aren't from and to ports
  	return true if @current_resource.ip_protocol == '-1'
  	# loop through options and make sure they match
    properties = %w{group ipProtocol fromPort toPort}
  	current_options = Hash.new
    new_options = Hash.new
    properties.map{|key| current_options[key] = ip_permission[key] ; new_options[key] = new_ip_permission[key] }
    return true if current_options.eql? new_options
  end
  # didn't match anything above, rule doesn't exist
  false
end

def current_resource_ip_permissions
  groups = @current_resource.group ? [{ "userId" => @current_resource.owner, "groupId" => current_resource.group }] : []
  ipRange = @current_resource.cidr_ip ? [{ "cidrIp" => @current_resource.cidr_ip } ] : []
  rule = {
  	"groups" 	   => groups,
  	"ipRanges" 	 => ipRange,
  	"ipProtocol" => @current_resource.ip_protocol,
  }
  unless rule["ipProtocol"] == '-1'
    rule["fromPort"] = @current_resource.from_port
  	rule["toPort"] = @current_resource.to_port
  end
  rule
end

def construct_security_group_options
  options = { ip_protocol: @current_resource.ip_protocol }
  if @current_resource.cidr_ip
    options[:cidr_ip] = @current_resource.cidr_ip
  else
    options[:group] = { @current_resource.owner => @current_resource.group }
  end
  options
end

def security_group
	@groupid ||= ec2.security_groups.get_by_id(@current_resource.groupid)
end

def security_groupname
  @groupname ||= ec2.security_groups.all('group-name' => [@current_resource.groupname]).first
end
