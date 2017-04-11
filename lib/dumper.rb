require 'socket'

module Dumper
  autoload :Agent,      'dumper/agent'
  autoload :Cli,        'dumper/cli'
  autoload :Dependency, 'dumper/dependency'
  autoload :Job,        'dumper/job'
  autoload :Stack,      'dumper/stack'
  autoload :VERSION,    'dumper/version'

  module Database
    autoload :Base,       'dumper/database/base'
    autoload :MySQL,      'dumper/database/mysql'
    autoload :PostgreSQL, 'dumper/database/postgresql'
    autoload :MongoDB,    'dumper/database/mongodb'
    autoload :Redis,      'dumper/database/redis'
  end

  module Utility
    autoload :IP,           'dumper/utility/ip'
    autoload :Log,          'dumper/utility/log'
    autoload :ObjectFinder, 'dumper/utility/object_finder'
  end
end
