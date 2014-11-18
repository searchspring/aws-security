include Aws::Ec2

def whyrun_supported?
  true
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Creating #{ @new_resource } security group") do
      create_security_group(@current_resource)
    end
  end
end

action :remove do
  if @current_resource.exists
    fail "#{ @new_resource } cannot be removed - configuration " \
      'mismatch' unless security_group
    converge_by("Remvoing #{ @new_resource } security group") do
	    security_group.destroy
    end
  else
  	Chef::Log.info "#{ @new_resource } does not exist - nothing to do."
  end
end

def load_current_resource
  @current_resource = Chef::Resource::AwsSecurityGroup.new(@new_resource.groupname)

  %w(groupname
    description
    vpcid
    region).each do |attrib|
    @current_resource.send(attrib, @new_resource.send(attrib))
  end

  @current_resource.aws_access_key_id(@new_resource.aws_access_key_id || node['aws_security']['aws_access_key_id'])
  @current_resource.aws_secret_access_key(@new_resource.aws_secret_access_key || node['aws_security']['aws_secret_access_key'])

  @current_resource.exists = true if security_group_exists?(@current_resource)
end

def security_group
    @sg ||= ec2.security_groups.all('group-name' => [ @current_resource.groupname ] ).first
end

def create_security_group(current_resource)
  ec2.security_groups.new(attributes(current_resource)).save
end

def attributes(current_resource)
  attributes = {
    :name         => current_resource.groupname,
    :description  => current_resource.description,
    :region       => current_resource.region
  }
  attributes[:vpc_id] = current_resource.vpcid if current_resource.vpcid
  return attributes
end
