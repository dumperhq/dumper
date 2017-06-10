module Dumper
  module Database
    class Redis < Base
      DUMP_TOOL = 'redis-cli'
      FORMAT = 'rdb'

      def command
        uncompressed = filename.sub('.gz','')
        "cd #{tmpdir} && cp #{@config[:dbpath]} #{uncompressed} && gzip #{uncompressed}"
      end

      def set_config
        return unless main_thread_redis = first_instance_of('::Redis')

        client = main_thread_redis.client

        # New connection for the agent thread
        redis = ::Redis.new(:host => client.host, :port => client.port, :password => client.password, :db => client.db)
        dir         = redis.config(:get, :dir)['dir']
        dbfilename  = redis.config(:get, :dbfilename)['dbfilename']
        dbpath = "#{dir}/#{dbfilename}"

        return unless File.exist?(dbpath) # Redis must run on the back up node

        @config = {
          :host => client.host,
          :port => client.port,
          :password => client.password,
          :database => client.db,
          :dump_tool => dump_tool_path,
          :dbpath => dbpath
        }
      end
    end
  end
end
