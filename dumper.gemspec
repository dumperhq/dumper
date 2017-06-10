# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dumper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Kenn Ejima']
  gem.email         = ['kenn.ejima@gmail.com']
  gem.description   = 'Dumper is a backup management system that offers a whole new way to take daily backups of your databases.'
  gem.summary       = 'The Dumper Agent for Rails'
  gem.homepage      = 'https://github.com/kenn/dumper'

  gem.files         = `git ls-files`.split($\)
  gem.bindir        = 'exe'
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'dumper'
  gem.require_paths = ['lib']
  gem.version       = Dumper::VERSION

  gem.add_runtime_dependency 'multipart-post', '>= 1.1.5'
  gem.add_runtime_dependency 'posix-spawn', '>= 0.3.6'

  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'mysql2'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'redis'
  gem.add_development_dependency 'rspec'

  # For Travis
  gem.add_development_dependency 'rake'
end
