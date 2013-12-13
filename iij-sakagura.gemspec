# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iij/sakagura/version'

Gem::Specification.new do |spec|
  spec.name          = "iij-sakagura"
  spec.version       = IIJ::Sakagura::VERSION
  spec.authors       = ["Takahiro HIMURA"]
  spec.email         = ["taka@himura.jp"]
  spec.description   = %q{IIJ API platform (Sakagura) SDK}
  spec.summary       = %q{IIJ API platform (Sakagura) SDK}
  spec.homepage      = "https://github.com/iij/ruby-iij-sakagura"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
end
