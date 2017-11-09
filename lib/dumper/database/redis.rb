module Dumper
  module Database
    class Redis < Base
      DUMP_TOOL = 'redis-cli'
      FORMAT = 'rdb'

      def command
        uncompressed = filename.sub('.gz','')
        "cd #{tmpdir} && cp #{@config[:dbpath]} #{uncompressed} && gzip #{uncompressed}"
      end

      def set_config_for(rails_env=nil)
        return unless defined?(::Redis) &&
          (main_thread_redis = find_instance_in_object_space(::Redis))

        # redis-rb v4 added CLIENT command support
        m = main_thread_redis.respond_to?(:_client) ? :_client : :client
        client = main_thread_redis.send(m)

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
