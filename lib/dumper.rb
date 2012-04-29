require 'thor'
require 'rainbow'
require 'socket'

module Dumper
  autoload :Cli,      'dumper/cli'
  autoload :Utility,  'dumper/utility'
  autoload :VERSION,  'dumper/version'
end
