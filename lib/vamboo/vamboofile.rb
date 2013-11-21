class VambooFile
	Vamboofile = "Vamboofile"
	attr_reader :vamboo_home

	def self.createAt(vamboo_home)
	  	FileUtils.mkdir_p(vamboo_home)
	  	FileUtils.copy("#{File.dirname(__FILE__)}/#{Vamboofile}.org", "#{vamboo_home}/#{Vamboofile}")
	end

	def initialize(vamboo_home)
		@vamboo_home = vamboo_home
	end

	def loadDomains
		domains = eval(File.read("#{@vamboo_home}/#{Vamboofile}"))
		domains
	end
end