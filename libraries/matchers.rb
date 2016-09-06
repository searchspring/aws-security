if defined?(ChefSpec)
  def create_if_missing_aws_security_group(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:aws_security_group, :create_if_missing, resource_name)
  end

  def remove_aws_security_group(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:aws_security_group, :remove, resource_name)
  end

  def add_aws_security_group_rule(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:aws_security_group_rule, :add, resource_name)
  end

  def remove_aws_security_group_rule(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:aws_security_group_rule, :remove, resource_name)
  end
end
