module Dumper
  module Database
    class Redis < Base
      DUMP_TOOL = 'redis-cli'
      FILE_EXT = 'rdb.gz'

      def command
        uncompressed = filename.sub('.gz','')
        "cd #{tmpdir} && cp #{@stack.configs[:redis][:dbpath]} #{uncompressed} && gzip #{uncompressed}"
      end

      def config_for(rails_env=nil)
        return unless defined?(::Redis) &&
          (main_thread_redis = find_instance_in_object_space(::Redis))

        client = main_thread_redis.client

        # New connection for the agent thread
        redis = ::Redis.new(:host => client.host, :port => client.port, :password => client.password, :db => client.db)
        dir         = redis.config(:get, :dir)['dir']
        dbfilename  = redis.config(:get, :dbfilename)['dbfilename']
        dbpath = "#{dir}/#{dbfilename}"

        return unless File.exist?(dbpath) # Redis must run on the back up node

        {
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
