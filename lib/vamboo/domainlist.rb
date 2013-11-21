class DomainList
	attr_reader :list
	def self.define(&block)
	end

	def initialize(&block)
		instance_eval(&block)
	end

	def add(name, vmhd_path)
		list.push(Domain.new(name, vmhd_path))
	end
end

class Domain
	attr_reader :name, :vmhd_path

	def initialize(name, vmhd_path)
		@name = name
		@vmhd_path = vmhd_path
	end

	def backup
		p self
	end
end