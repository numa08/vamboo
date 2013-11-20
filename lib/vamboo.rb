require "vamboo/version"

module Vamboo

	def self.default_vamboo_home
		vamboo_home = if ENV.key?('VAMBOO_HOME')
	  		ENV['VAMBOO_HOME']
	  	else
	  		'/usr/local/etc/vamboo'
	  	end
	  	vamboo_home
	end

	def initialize(vamboo_home)
		#TODO : create vamboo file
	end
end
