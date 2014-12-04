# aws_security

Description
===========

This cookbook provides libraries, resource and providers to config and mangage Amazon Ec2 Security Groups

Requirements
============
## Cookbooks
* fog_gem

## Gems
* fog

## Testing Gems
* berkshelf
* test-kitchen
* kitchen-vagrant
* chefspec
* rspec_junit_formatter

AWS Credentials
===============

The default recipe will look for a encrypted data bag defined by node['aws_security']['encrypted_data_bag'] with the following keys
* aws_access_key_id
* aws_secret_access_key

E.G.
```json
{
    "id": "aws",
    "aws_access_key_id": "YOUR_ACCESS_KEY",
    "aws_secret_access_key": "YOUR_SECRET_ACCESS_KEY"
}
```

Recipes
=======

default
-------

The default recipe includes the 'build-essential' cookbook and chef_gem installs the fog gem.

Attributes
==========

`default['build-essential']['compile_time'] = true`
This must be set to true to ensure development tools are installed before the chefgem 'fog' is installed

`default['aws_security']['encrypted_data_bag'] = nil`
Name of the data bag to search for your AWS credentials

`default['aws_security']['aws_access_key_id'] = nil`
`default['aws_security']['aws_secret_access_key'] = nil`
If these are defined, they will be used by default for the LWRPs



LWRPs
=====

`aws_security_group`
-------------------- 
Description:
Creates and destroys security groups

Actions:
* `create_if_missing` - Creates a new security group if it doesn' alreay exist (default action)
* `remove` - Removes an existing security group

Attribute Parameters:
* `groupname` - Name attribute
* `aws_access_key_id` - optional (falls back to IAM roles if not provided)
* `aws_secret_access_key` - required if aws_access_key_id is specified
* `description` - required
* `vpcid` - optional
* `region` - optional (defaults to 'us-east-1')

## Usage

aws_security_group 'Example' do
  description "Example Security Group"
  aws_access_key_id node['aws_security']['aws_access_key_id'] 
  aws_secret_access_key node['aws_security']['aws_secret_access_key']
  region 'us-west-2'
end


`aws_security_group_rule`
-------------------------
Description:
Creates and destroys rules in an existing security group

Actions:
* `add` - Adds new rule to existing security group (default action)
* `remove` - Removes an existing rule from a security group

Attribute Parameters:
* `name` - Name attribute
* `aws_access_key_id` - required
* `aws_secret_access_key` - required
* `groupname` - optional
* `description` - optional 
* `vpcid` - optional
* `region` - optional (defaults to 'us-east-1')
* `groupid` - optional
* `groupname` - optional
* `cidr_ip` - optional
* `group` - optional
* `owner` - optional
* `ip_protocolo` - optional, (must be one of the following [-1,udp,tcp,icmp])
* `port_range` - optional (port..port)
* `from_port` - optional
* `to_port` - optional

## Usage

The following will create a rule in security group `Example` in region `us-west-2` to allow 192.168.1.1 access to port 80

```ruby
aws_security_group_rule 'example1' do
  description "Example Rule 1"
  aws_access_key_id node['aws_security']['aws_access_key_id']
  aws_secret_access_key node['aws_security']['aws_secret_access_key']
  cidr_ip "192.168.1.1/32"
  groupname "Example"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'tcp'
end
```

The following will create a rule in security group `Example` in region `us-west-2` to allow a security group with the id of `sg-3b5a6ffe` to allow access to port 80 

```ruby
aws_security_group_rule 'exmaple2' do
  description "Example Rule 2"
  aws_access_key_id node['aws_security']['aws_access_key_id']
  aws_secret_access_key node['aws_security']['aws_secret_access_key']
  group "sg-3b5a6ffe"
  groupname "Example"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'tcp'
end
```

The following will create a rule in security group `Example` in region `us-east-1` to allow 10.0.0.0/24 all access

```ruby
aws_security_group_rule 'example3' do
  description "Example Rule 3"
  aws_access_key_id node['aws_security']['aws_access_key_id']
  aws_secret_access_key node['aws_security']['aws_secret_access_key']
  cidr_ip "10.0.0.0/24"
  groupname "Example"
  ip_protocol '-1'
end
```

TODO
====

* Egress rules
* Apply security groups to instances, elbs, vpcs, etc


License and Author
==================

* Author:: Greg Hellings (<greg@thesub.net>)


Copyright 2014, B7 Interactive, LLC.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



