module Dumper
  module Database
    class Base
      include Dumper::Utility::ObjectFinder

      attr_accessor :tempfile

      def initialize(stack = nil, options = {})
        @stack = stack
        @options = options
      end

      def file_ext
        self.class::FILE_EXT
      end

      def dump_tool_path
        tool = self.class::DUMP_TOOL
        path = `which #{tool}`.chomp
        if path.empty?
          # /usr/local/mysql/bin = OSX binary, /usr/local/bin = homebrew, /usr/bin = linux
          dir = [ '/usr/local/mysql/bin', '/usr/local/bin', '/usr/bin' ].find do |i|
            File.exist?("#{i}/#{tool}")
          end
          path = "#{dir}/#{tool}" if dir
        end
        path
      end
    end
  end
end
