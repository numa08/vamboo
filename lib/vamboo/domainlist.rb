require "libvirt"
require "zlib"
require "logger"
require "archive/tar/minitar"

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
		log = Logger.new("#{target_path}/#{@name}.log")
		log.formatter = proc do |severity, datetime, progname, msg|
   				"#{@name}:#{datetime}: #{msg}\n"
		end


		conn = Libvirt::open("qemu:///system")
		domain = conn.lookup_domain_by_name(@name)
		tmp_path = "#{Vamboo.default_vamboo_home}/#{@name}"
		
		log.info("Start backup")
		active = domain.active?
		if active
			log.info("Shutdown")
			domain.shutdown
			sleep(10) while domain.active?
		end

		log.info("Dump xml")
		FileUtils.mkdir_p(tmp_path)
		File.open("#{tmp_path}/#{@name}.xml", "w") do |file|
			xml = domain.xml_desc
			file.write(xml)
		end

		log.info("Compress vmhd")
		File.open("#{@vmhd_path}", "rb") do |vmhd|
			Zlib::GzipWriter.open("#{tmp_path}/#{@name}.img.gz", Zlib::BEST_COMPRESSION) do |gz|
				offset = 0
				length = 1024
				while offset < vmhd.size
					gz.print(IO.binread(vmhd.path, length, offset))
					offset += length
				end
			end
		end

		if active
			log.info("Start")
			domain.create
			sleep(10) until domain.active?
		end

		log.info("Archive")
		Zlib::GzipWriter.open("#{target_path}/#{@name}.tar.gz") do |archive|
			out = Archive::Tar::Minitar::Output.new(archive)
			Find.find("#{tmp_path}") do |file|
				Archive::Tar::Minitar::pack_file(file, out)
			end
			out.close
		end	
		FileUtils.rm_rf("#{tmp_path}")

		log.info("Complete backup")
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

	def verify
		"#{@name}	#{@vmhd_path}"
	end
end