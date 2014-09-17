#
# Cookbook Name:: aws_security
# Recipe:: default
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

include_recipe "build-essential"
chef_gem "fog"

if node['aws_security']['encrypted_data_bag']
  databag_item = Chef::EncyptedDataBagItem.load(
  	aws_keys,
    node['aws_security']['encrypted_data_bag']
  )
  default['aws_security']['aws_access_key_id'] = databag_item['aws_access_key_id']
  default['aws_security']['aws_secret_access_key'] = databag_item['aws_secret_access_key']
end

