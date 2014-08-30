module Dumper
  module Database
    class Base
      include Dumper::Utility::ObjectFinder

      attr_accessor :tmpdir, :filename, :config, :custom_options, :format

      def file_ext
        (format || self.class::FORMAT) + '.gz'
      end

      def dump_path
        "#{tmpdir}/#{filename}"
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

      def finalize
        FileUtils.remove_entry_secure(tmpdir) if tmpdir and File.exist?(tmpdir)
      end
    end
  end
end
