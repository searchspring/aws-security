include Aws::Ec2

def whyrun_supported?
  true
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Creating #{@new_resource} security group") do
      create_security_group
    end
  end
end

action :create_and_attach do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists."
  else
    converge_by("Creating #{@new_resource} security group") do
      create_security_group
    end
  end
  add_instance_to_security_group(instance)
end

action :remove do
  if @current_resource.exists
    raise "#{@new_resource} cannot be removed - configuration " \
      'mismatch' unless security_group
    converge_by("Remvoing #{@new_resource} security group") do
      security_group.destroy
    end
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

action :attach do
  if @current_resource.exists
    add_instance_to_security_group(instance)
  else
    raise "#{@new_resource} does not exist - unable to attach."
  end
end

action :detach do
  if @current_resource.exists
    remove_instance_from_security_group(instance)
  else
    Chef::Log.info "#{@new_resource} does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource =
    Chef::Resource::AwsSecurityGroup.new(@new_resource.groupname)

  %w(aws_access_key_id
     aws_secret_access_key
     groupname
     description
     vpcid
     region).each do |attrib|
    @current_resource.send(attrib, @new_resource.send(attrib))
  end

  if @new_resource.aws_access_key_id || node['aws_security']['aws_access_key_id']
    @current_resource.mocking(@new_resource.mocking ||
      node['aws_security']['mocking'])
  end
  @current_resource.exists = true if security_group
end

def security_group
  @sg ||= ec2.security_groups.all(
    'group-name' => [@current_resource.groupname]
  ).find { |g| g.vpc_id == @current_resource.vpcid }
end

def create_security_group
  ec2.security_groups.new(attributes).save
end

def add_instance_to_security_group(instance)
  existing_groups = instance.network_interfaces.first['groupIds']

  unless existing_groups.include?(security_group.group_id)
    ec2.modify_instance_attribute(instance.id, 'GroupId' => (existing_groups + [security_group.group_id]))
  end
end

def remove_instance_from_security_group(instance)
  existing_groups = instance.network_interfaces.first['groupIds']

  if existing_groups.include?(security_group.group_id)
    ec2.modify_instance_attribute(instance.id, 'GroupId' => (existing_groups - [security_group.group_id]))
  end
end

def attributes
  attributes = {
    name:        @current_resource.groupname,
    description: @current_resource.description,
    region:      @current_resource.region
  }
  attributes[:vpc_id] = @current_resource.vpcid if @current_resource.vpcid
  attributes
end

def instance
  instance_host = '169.254.169.254'
  instance_id_url = '/latest/meta-data/instance-id'

  httpcall = Net::HTTP.new(instance_host)
  resp = httpcall.get2(instance_id_url)

  @instance ||= ec2.servers.get(resp.body)
end
