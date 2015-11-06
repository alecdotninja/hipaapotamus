# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hipaapotamus/version'

Gem::Specification.new do |spec|
  spec.name          = 'hipaapotamus'
  spec.version       = Hipaapotamus::VERSION
  spec.authors       = ['Alec Larsen', 'Jacob Lee']

  spec.summary       = %q{Hipaapotamus is an amazing gem for amazing people}
  spec.homepage      = 'https://github.com/anarchocurious/hipaapotamus'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency 'activerecord', '~> 4.1'
  spec.add_runtime_dependency 'activesupport', '~> 4.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3', '1.3.11'
  spec.add_development_dependency 'database_cleaner', '1.0.1'
end
