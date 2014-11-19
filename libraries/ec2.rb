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

module Aws
  module Ec2
    def ec2
      @@ec2 ||= create_aws_interface
    end

    def create_aws_interface
      begin
        require 'fog'
      rescue LoadError
        Chef::Log.error("Missing gem 'fog'")
      end
      Fog::Compute.new(
        :provider              => 'AWS',
        :aws_access_key_id     => @current_resource.aws_access_key_id,
        :aws_secret_access_key => @current_resource.aws_secret_access_key,
        :region                => @current_resource.region
      )
    end
  end
end
