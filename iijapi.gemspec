# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iijapi/version'

Gem::Specification.new do |spec|
  spec.name          = "iijapi"
  spec.version       = IIJAPI::VERSION
  spec.authors       = ["Takahiro HIMURA"]
  spec.email         = ["taka@himura.jp"]
  spec.description   = %q{IIJ API SDK}
  spec.summary       = %q{IIJ API SDK}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
end
