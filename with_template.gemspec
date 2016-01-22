
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'with_template/version'

Gem::Specification.new do |spec|
  spec.name          = "with_template"
  spec.version       = WithTemplate::VERSION
  spec.authors       = ["Andrew Hunter"]
  spec.email         = ["hunterae@gmail.com"]
  spec.summary       = %q{Render a template (partial) and easily override any of the components of the template}
  spec.description   = %q{Render a template (partial) and easily override any of the components of the template}
  spec.homepage      = "http://github.com/hunterae/with_template"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 3.0.0"
  spec.add_dependency "blocks", "~> 2.8.0"

  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "shoulda", "~> 3.5.0"
  spec.add_development_dependency "mocha"
end
