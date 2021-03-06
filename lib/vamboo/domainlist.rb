require "date"
require "libvirt"
require "zlib"
require "logger"
require "archive/tar/minitar"
require "rexml/document"

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

	def add(name, rotation)
		@list.push(Domain.new(name, rotation))		
	end
end

class Domain
	attr_reader :name, :rotation, :vmhd_pathes

	def initialize(name, rotation)
		@name = name
		@rotation = rotation
		conn = Libvirt::open("qemu:///system")
		domain = conn.lookup_domain_by_name(@name)
		xml = REXML::Document.new(domain.xml_desc)
		@vmhd_pathes = xml.elements.to_a("domain/devices/disk[@type='file']").map do |dev|
			dev.elements['source'].attributes['file']
		end
		conn.close
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

		log.info("Copy vmhd")
		threads = @vmhd_pathes.map do |vmhd_path|
			Thread.new do
				name = File.basename(vmhd_path)
				FileUtils.cp("#{vmhd_path}", "#{tmp_path}/#{name}")
			end
		end

		threads.each do |t|
			t.join
		end

		if active
			log.info("Start")
			domain.create
			sleep(10) until domain.active?
		end

		log.info("Compress vmhd")
		@vmhd_pathes.each do |vmhd_path|
			name = File.basename(vmhd_path)
			tmp = "#{tmp_path}/#{name}"
			File.open(tmp, "rb") do |vmhd|
				Zlib::GzipWriter.open("#{tmp}.gz", Zlib::BEST_COMPRESSION) do |gz|
					offset = 0
					length = 1024
					while offset < vmhd.size
						gz.print(IO.binread(vmhd.path, length, offset))
						offset += length
					end
				end
			end
			FileUtils.rm(tmp, {:force => true})
		end

		log.info("Archive")
		file_name = "#{@name}.#{Date.today.strftime("%Y%m%d")}.tar.gz"
		Zlib::GzipWriter.open("#{target_path}/#{file_name}") do |archive|
			out = Archive::Tar::Minitar::Output.new(archive)
			Find.find("#{tmp_path}") do |file|
				Archive::Tar::Minitar::pack_file(file, out)
			end
			out.close
		end	
		FileUtils.rm_rf("#{tmp_path}")
		
		if @rotation > 0 
			old = Date.today - @rotation
			old_file = "#{@name}.#{old}.tar.gz"
			log.info("Remove old file #{target_path}/#{old}")
			FileUtils.rm_rf("#{target_path}/#{old}")
		end
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
		@vmhd_pathes.all? do |vmhd_path|
			File.exist?(vmhd_path)
		end
	end

	def verify
		"#{@name}	#{@vmhd_pathes}"
	end
end
