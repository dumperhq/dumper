require 'socket'

module Dumper
  autoload :Agent,      'dumper/agent'
  autoload :Cli,        'dumper/cli'
  autoload :Dependency, 'dumper/dependency'
  autoload :Job,        'dumper/job'
  autoload :Stack,      'dumper/stack'
  autoload :Utility,    'dumper/utility'
  autoload :VERSION,    'dumper/version'

  module Database
    autoload :Base,       'dumper/database/base'
    autoload :MySQL,      'dumper/database/mysql'
    autoload :PostgreSQL, 'dumper/database/postgresql'
    autoload :MongoDB,    'dumper/database/mongodb'
    autoload :Redis,      'dumper/database/redis'
  end
end
