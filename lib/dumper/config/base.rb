require 'posix/spawn'

module Dumper
  module Config
    class Base
      include POSIX::Spawn
      include Dumper::Utility::ObjectFinder

      attr_reader :host, :port, :database, :username, :password
    end
  end
end
