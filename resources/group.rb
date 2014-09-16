actions :create_if_missing, :remove

default_action :create_if_missing

attribute :groupname,			  :kind_of => String, :name_attribute => true, :required => true
attribute :description,  		  :kind_of => String, :required => false
attribute :vpcid,				  :kind_of => String, :required => false
attribute :aws_access_key_id,	  :kind_of => String, :required => false
attribute :aws_secret_access_key, :kind_of => String, :required => false
attribute :region,				  :kind_of => String, :required => true


attr_accessor :exists