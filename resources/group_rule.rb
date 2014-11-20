actions :add, :remove

default_action :add

attribute :groupid,				  :kind_of => String
attribute :groupname,             :kind_of => String
attribute :name,  		  		  :kind_of => String, :name_attribute => true, :required => false
attribute :description,           :kind_of => String
attribute :cidr_ip,				  :kind_of => String
attribute :group,                 :kind_of => String
attribute :owner,				  :kind_of => String
attribute :ip_protocol,           :kind_of => String, :default => '-1', :equal_to => %w[-1 tcp udp icmp]
attribute :port_range,            :kind_of => String 
attribute :aws_access_key_id,	  :kind_of => String, :required => false
attribute :aws_secret_access_key, :kind_of => String, :required => false
attribute :region,				  :kind_of => String, :default => 'us-east-1'
attribute :from_port,			  :kind_of => Integer, :default => 0
attribute :to_port,               :kind_of => Integer, :default => 65535

attr_accessor :exists
