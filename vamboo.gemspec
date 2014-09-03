# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vamboo/version'

Gem::Specification.new do |spec|
  spec.name          = "vamboo"
  spec.version       = Vamboo::VERSION
  spec.authors       = ["numa08", "funabiki.t"]
  spec.email         = ["n511287@gmail.com", "funabiki.t@isoroot.jp"]
  spec.description   = "you can easy backup virtual machines"
  spec.summary       = "virtual machine backup util"
  spec.homepage      = "https://github.com/numa08/vamboo"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = 'bin'

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "ruby-libvirt", "~> 0.5"
  spec.add_runtime_dependency "archive-tar-minitar", "~> 0.5"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake" , "~> 10.1"
end
