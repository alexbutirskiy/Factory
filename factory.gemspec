# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'factory/version'

Gem::Specification.new do |spec|
  spec.name          = "alex_butirskiy_factory"
  spec.version       = FactoryModule::VERSION
  spec.authors       = ["Alex Butirskiy"]
  spec.email         = ["butirskiy@gmail.com"]
  spec.summary       = %q{Factory creates new data types like Struct class}
  spec.homepage      = "https://github.com/alexbutirskiy/factory"
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
end
