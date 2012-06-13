# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nanoc/sprockets/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Nishinaga"]
  gem.email         = ["jingoro@casa-z.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nanoc-sprockets"
  gem.require_paths = ["lib"]
  gem.version       = Nanoc::Sprockets::VERSION

  gem.add_dependency 'nanoc', '>= 3.4.0'
  gem.add_dependency 'sprockets', '~> 2.1.0'
  gem.add_dependency 'rack', '>= 0'
  gem.add_dependency 'mime-types', '>= 0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'bluecloth'

end
