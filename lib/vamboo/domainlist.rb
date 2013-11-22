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
	attr_reader :name, :vmhd_path

	def initialize(name, vmhd_path)
		@name = name
		@vmhd_path = vmhd_path
	end

	def backup

	end

	def isDefined?
		true
	end

	def vmhdIsExist?
		true
	end
end