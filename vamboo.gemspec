# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vamboo/version'

Gem::Specification.new do |spec|
  spec.name          = "vamboo"
  spec.version       = Vamboo::VERSION
  spec.authors       = ["funabiki.t"]
  spec.email         = ["funabiki.t@isoroot.jp"]
  spec.description   = "virtual machine backup util"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "libvirt"
end