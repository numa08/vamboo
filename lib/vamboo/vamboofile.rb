class VambooFile
	Vamboofile = "Vamboofile"
	attr_reader :vamboo_home

	def self.createAt(vamboo_home)
	  	FileUtils.mkdir_p(vamboo_home)
	  	if File.exist?("#{vamboo_home}/#{Vamboofile}")
	  		return
	  	end
	  	FileUtils.copy("#{File.dirname(__FILE__)}/#{Vamboofile}.org", "#{vamboo_home}/#{Vamboofile}")
	end

	def initialize(vamboo_home)
		@vamboo_home = vamboo_home
	end

	def loadDomains
		domains = eval(File.read("#{@vamboo_home}/#{Vamboofile}"))
		domains.each do |domain|
			unless domain.isDefined?
				raise "#{domain.name} is not defined!!"
			end
			unless domain.vmhdIsExist?
				raise "#{domain.name}'s vmhd is not exist!!"
			end
		end
		domains
	end
end