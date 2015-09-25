# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'analytics/version'

Gem::Specification.new do |spec|
  spec.name = 'analytics'
  spec.version = Analytics::VERSION
  spec.authors = ['Learning Tapestry']
  spec.email = ['steve@learningtapestry.com']

  spec.summary = "Ruby Client for accessing Learning Tapestry's
    Analytics API"
  spec.description = "Allows retrieving collected data from Learning
    Tapestry's Analytics API"
  spec.homepage = 'https://github.com/learningtapestry/analytics-ruby-client'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 1.9.3'
  spec.extra_rdoc_files = ['README.md']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
