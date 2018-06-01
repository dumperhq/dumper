module Dumper
  module Config
    class Redis < Base
      def initialize(additional_env: nil)
        return unless exist?

        @host = @client.host
        @port = @client.port
        @database = @client.db
        @password = @client.password
      end

      def exist?
        return unless main_thread_redis = first_instance_of('::Redis')

        # redis-rb v4 added CLIENT command support
        m = main_thread_redis.respond_to?(:_client) ? :_client : :client
        @client = main_thread_redis.send(m)
      end
    end
  end
end
