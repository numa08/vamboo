require "vamboo/version"

module Vamboo
	attr_reader :vamboo_home

	def self.default_vamboo_home
		vamboo_home = ENV.fetch('VAMBOO_HOME', '/usr/local/etc/vamboo')
	  	vamboo_home
	end

	def initialize(vamboo_home)
		@vamboo_home = vamboo_home
	end

	def domains
		vambooFile = VambooFile.new(vamboo_home)
		domains = vambooFile.loadDomains
		domains
	end

	def findDomain(name, vmhd_path)
	end

end

class VambooKernel 
	include Vamboo
end