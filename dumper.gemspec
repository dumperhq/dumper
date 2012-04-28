# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dumper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kenn Ejima"]
  gem.email         = ["kenn.ejima@gmail.com"]
  gem.description   = %q{Utility that checks the status of a database}
  gem.summary       = %q{Utility that checks the status of a database}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dumper"
  gem.require_paths = ["lib"]
  gem.version       = Dumper::VERSION

  gem.add_runtime_dependency "thor"
  gem.add_runtime_dependency "rainbow"
end
