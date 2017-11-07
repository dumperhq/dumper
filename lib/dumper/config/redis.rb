module Dumper
  module Config
    class Redis < Base
      def initialize(additional_env: nil)
        return unless exist?

        @host = @client.host
        @port = @client.port
        @database = @client.db
        @password = @client.password
        @dbpath = dbpath
      end

      def exist?
        return unless main_thread_redis = first_instance_of('::Redis')

        # redis-rb v4 added CLIENT command support
        m = main_thread_redis.respond_to?(:_client) ? :_client : :client
        @client = main_thread_redis.send(m)

        # New connection for the agent thread
        redis = ::Redis.new(host: @client.host, port: @client.port, password: @client.password, db: @client.db)
        dir         = redis.config(:get, :dir)['dir']
        dbfilename  = redis.config(:get, :dbfilename)['dbfilename']
        dbpath = "#{dir}/#{dbfilename}"

        return unless File.exist?(dbpath) # Redis must run on the back up node
      end
    end
  end
end
