module Dumper
  module Database
    class Redis < Base
      DUMP_TOOL = 'redis-cli'
      FORMAT = 'rdb'

      def command
        uncompressed = filename.sub('.gz','')
        # "cd #{tmpdir} && cp #{@config[:dbpath]} #{uncompressed} && gzip #{uncompressed}"
        "cd #{tmpdir} && redis-cli #{connection_options} #{credential} --rdb #{uncompressed} && gzip #{uncompressed}"
      end

      def connection_options
        "-h #{config.host} -p #{config.port}"
      end

      def credential
        config.password && "-a #{config.password}"
      end

      def set_config
        config = Dumper::Config::Redis.new
        return unless config.exist?

        @old_config = {
          :host => client.host,
          :port => client.port,
          :password => client.password,
          :database => client.db,
          :dump_tool => dump_tool_path
        }
      end
    end
  end
end
