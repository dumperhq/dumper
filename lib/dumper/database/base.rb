module Dumper
  module Database
    class Base
      def initialize(stack)
        @stack = stack
      end

      class << self
        include Dumper::Utility::ObjectFinder

        def dump_tool_path(name)
          path = `which #{name}`.chomp
          if path.empty?
            # /usr/local/mysql/bin = OSX binary, /usr/local/bin = homebrew, /usr/bin = linux
            dir = [ '/usr/local/mysql/bin', '/usr/local/bin', '/usr/bin' ].find do |i|
              File.exist?("#{i}/#{name}")
            end
            path = "#{dir}/#{name}" if dir
          end
          path
        end
      end
    end
  end
end
