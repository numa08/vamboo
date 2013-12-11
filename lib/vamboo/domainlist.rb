require "libvirt"
require "zlib"

class DomainList
	attr_reader :list
	def self.define(&block)
		domainList = DomainList.new(&block)
		list = domainList.list
		list
	end

	def initialize(&block)
		@list = []
		instance_eval(&block)
	end

	def add(name, vmhd_path)
		@list.push(Domain.new(name, vmhd_path))
	end
end

class Domain
	attr_reader :name, :vmhd_paths

	def initialize(name, vmhd_path)
		@name = name
		@vmhd_path = vmhd_path
	end

	def backup(target_path)
		conn = Libvirt::open("qemu:///system")
		domain = conn.lookup_domain_by_name(@name)
		tmp_path = "#{Vamboo.default_vamboo_home}/#{@name}"
		domain.shutdown
		
		FileUtils.mkdir_p(tmp_path)
		File.open("#{tmp_path}/#{@name}.xml", "w") do |file|
			xml = domain.xml_desc
			file.write(xml)
		end
		File.open("#{vmhd_path}", "r") do |vmhd|
			Zlib::GzipWriter.open("#{tmp_path}/#{@name}.img.gz") do |gz|
				gz.puts(vmhd.read)
			end
		end

		domain.create

		Zlib::GzipWriter.open("#{target_path}/#{@name}.tar.gz") do |archive|
			out = Archive::Tar::Minitar::Output.new(archive)
			Find.find("#{tmp_path}") do |file|
				Archive::Tar::Minitar::pack_file(file, out)
			end
			out.close
		end	
		FileUtils.rmdir("#{tmp_path}", :force => true)
	end

	def isDefined?
		retval = false
		begin
			Libvirt::open("qemu:///system").lookup_domain_by_name(@name)
			retval = true
		rescue  => e
			retval = false
		end
		retval
	end

	def vmhdIsExist?
		File.exist?(@vmhd_path)
	end
end