#
# Cookbook Name:: fake
# Recipe:: test2
#
# Author:: Greg Hellings (<greg@thesub.net>)
# 
# 
# Copyright 2014, B7 Interactive, LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "aws_security::default"
include_recipe "python"


python_pip "awscli"

directory "/root/.aws" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/root/.aws/config" do
  source 'aws_config.erb'
  owner 'root'
  group 'root'
  variables({
    :aws_access_key_id => node['aws_security']['aws_access_key_id'],
    :aws_secret_access_key => node['aws_security']['aws_secret_access_key']
  })
end

aws_security_group_rule 'test rule 1' do
  description "test rule 1"
  cidr_ip "192.168.1.1/32"
  groupname "test"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'tcp'
  action :remove
end

aws_security_group_rule 'test rule 2' do
  cidr_ip "192.168.1.2/32"
  groupname "test"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'udp'
  action :remove
end

aws_security_group_rule 'test rule 3' do
  cidr_ip "192.168.1.3/32"
  groupname "test"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'tcp'
  action :remove
end

aws_security_group_rule 'test rule 4' do
  cidr_ip "192.168.1.3/32"
  groupname "test"
  region 'us-west-2'
  ip_protocol '-1'
  action :remove
end

aws_security_group_rule 'test rule 5' do
  group "sg-9b1a8ffe"
  groupname "test"
  region 'us-west-2'
  port_range "80..80"
  ip_protocol 'tcp'
  action :remove
end

aws_security_group_rule 'test rule 6' do
  group "sg-9b1a8ffe"
  groupname "test"
  region 'us-west-2'
  ip_protocol 'tcp'
  action :remove
end

aws_security_group 'test' do
  description "test security group"
  region 'us-west-2'
  action :remove
end
