include Aws::Ec2

def whyrun_supported?
  true
end

action :add do
  validate!
  if @current_resource.exists
    Chef::Log.info("#{ @new_resource } already exists -- nothing to do")
  else
    fail "#{ new_resource } can not be created -- security group does not " \
      'exist' unless security_group
    require 'ipaddress'
    converge_by("Adding rule #{ @new_resource } to security group") do
      from_port = @current_resource.from_port
      to_port = @current_resource.to_port
      security_group.authorize_port_range(from_port..to_port,
                                          construct_security_group_options)
    end
  end
end

action :remove do
  if @current_resource.exists && security_group_rule_exact_match?
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

# rubocop:disable Metrics/CyclomaticComplexity
def validate!
  if @new_resource.group &&
     (@new_resource.source_group_name ||
      @new_resource.source_group_id)
    fail 'Cannot specify group and a source_group_* parameter at the same time'
  end
  return true unless @new_resource.source_group_name &&
                     @new_resource.source_group_id
  fail 'source_group_name and source_group_id cannot be specified at the ' \
       'same time.'
end
# rubocop:enable Metrics/CyclomaticComplexity

def load_current_resource
  @current_resource =
    Chef::Resource::AwsSecurityGroupRule.new(@new_resource.name)

  @current_resource.mocking(@new_resource.mocking ||
                            node['aws_security']['mocking'])

  %w(aws_access_key_id
     aws_secret_access_key
     groupname
     name
     cidr_ip
     group
     ip_protocol
     port_range
     owner
     region
  ).each do |attrib|
    @current_resource.send(attrib, @new_resource.send(attrib))
  end

  if @new_resource.group
    if group_is_id?(@new_resource.group)
      @current_resource.source_group_id(@new_resource.group)
    else
      @current_resource.source_group_name(@new_resource.group)
    end
  end

  if @current_resource.port_range
    (from_port, to_port) = @current_resource.port_range.split(/\.\./)
    @current_resource.from_port(from_port.to_i)
    @current_resource.to_port(to_port.to_i)
  else
    @current_resource.from_port(@new_resource.from_port)
    @current_resource.to_port(@new_resource.to_port)
  end
  if new_resource.groupid
    @current_resource.groupid(@new_resource.groupid)
  elsif security_groupname
    @current_resource.groupid(security_groupname.group_id)
  else
    return false
  end
  @current_resource.exists = security_group_rule_exists?
end

def group_is_id?(group)
  return true if group =~ /^sg-[a-zA-Z0-9]{8}$/
  false
end

def security_group_rule_exact_match?
  security_group.ip_permissions.each do |ip_permission|
    return true if permission_exact_match? ip_permission
  end
end

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
def permission_exact_match?(existing_rule)
  return false unless current_resource_ip_permissions['groups'].eql?(
                        existing_rule['groups']
                      )
  return false unless current_resource_ip_permissions['ipProtocol'] ==
                      existing_rule['ipProtocol']
  return false unless
    current_resource_ip_permissions['ipRanges'].sort_by { |r| r['cidrIp'] } ==
    existing_rule['ipRanges'].sort_by { |r| r['cidrIp'] }
  unless current_resource_ip_permissions['ipProtocol'] == '-1'
    return false unless existing_rule['fromPort'] ==
                        current_resource_ip_permissions['fromPort'] &&
                        existing_rule['toPort'] ==
                        current_resource_ip_permissions['toPort']
  end
  true
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

def security_group_rule_exists?
  security_group.ip_permissions.each do |ip_permission|
    return true if permissions_overlap? ip_permission
  end
  false
end

def permissions_overlap?(existing_rule)
  if permission_exact_match?(existing_rule)
    Chef::Log.debug('Permissions match exactly')
    return true
  end
  if current_resource_ip_permissions['groups'].any? && existing_rule['groups'].any?
    if current_resource_ip_permissions['groups'].first['groupid'] == existing_rule['groups'].first['groupid']
      return true if port_range_overlap?(existing_rule['fromPort'],
                                          existing_rule['toPort'])
    end
  end
  return false unless !current_resource_ip_permissions['ipRanges'].empty? &&
                      ip_range_covered?(existing_rule['ipRanges'])
  return false unless current_resource_ip_permissions['ipProtocol'] != '-1' &&
                      port_range_overlap?(existing_rule['fromPort'],
                                          existing_rule['toPort'])
  true
end

def ip_range_covered?(existing_ranges)
  return true if (current_resource_ip_permissions['ipRanges'] -
                  existing_ranges).empty?
  current_resource_ip_permissions['ipRanges'].each do |new_range|
    existing_ranges.each do |existing_range|
      return true if IPAddr.new(existing_range['cidrIp']).include?(
                       IPAddr.new(new_range['cidrIp'])
                     )
    end
  end
  false
end

def port_range_overlap?(existing_from_port, existing_to_port)
  existing_from_port <= current_resource_ip_permissions['fromPort'] &&
    existing_to_port >= current_resource_ip_permissions['toPort']
end

# rubocop:disable Metrics/MethodLength
def source_group
  return [] unless @current_resource.source_group_id ||
                   @current_resource.source_group_name
  o = { 'userId' => @current_resource.owner || security_group.owner_id }
  if @current_resource.source_group_id
    o['groupName'] = nil
    o['groupId']   = @current_resource.group
  else
    o['groupName'] = @current_resource.source_group_name
    o['groupId']   = nil
  end
  [o]
end
# rubocop:enable Metrics/MethodLength

def source_ip_ranges
  return [] unless @current_resource.cidr_ip
  [{ 'cidrIp' => @current_resource.cidr_ip }]
end

def current_resource_ip_permissions
  @current_resource_ip_permissions ||= begin
    rule = { 'groups'     => source_group,
             'ipRanges'   => source_ip_ranges,
             'ipProtocol' => @current_resource.ip_protocol }
    unless @current_resource.ip_protocol == '-1'
      rule['fromPort'] = @current_resource.from_port
      rule['toPort']   = @current_resource.to_port
    end
    rule
  end
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
  @security_group ||= ec2.security_groups.get_by_id(@current_resource.groupid)
end

def security_groupname
  @security_groupname ||= begin
    ec2.security_groups.all(
      'group-name' => [@current_resource.groupname]
    ).first
  end
end
