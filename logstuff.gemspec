# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logstuff/version'

Gem::Specification.new do |spec|
  spec.name          = "logstuff"
  spec.version       = Logstuff::VERSION
  spec.authors       = ["Paul Rhodes"]
  spec.email         = ["withnale@users.noreply.github.com"]
  spec.summary       = %q{Structured Logging for use with Logstash}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'request_store'
  spec.add_runtime_dependency 'logstash-event', '~> 1.1.0'

  spec.add_development_dependency('rspec', '>= 2.14')
  spec.add_development_dependency('bundler', '>= 1.0.0')
  spec.add_development_dependency('rails', '>= 3.0')
  spec.add_development_dependency "rake"
end
