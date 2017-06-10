require 'posix/spawn'

module Dumper
  module Config
    class Base
      include POSIX::Spawn
      include Dumper::Utility::ObjectFinder
    end
  end
end
