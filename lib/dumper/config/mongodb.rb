module Dumper
  module Config
    class MongoDB < Base
      def initialize(additional_env: nil)
        # @instance = instance || v5_or_later? ? first_instance_of('Mongo::Client') : first_instance_of('Moped::Session')
        return unless exist?

        @host = default['hosts'].first.split(/:/)[0]          # @instance.cluster.servers.first.address.host
        @port = default['hosts'].first.split(/:/)[1] || 27017 # @instance.cluster.servers.first.address.port
        @database = default['database']                       # @instance.database.name
        @username = default['user']
        @password = default['password']
      end

      def exist?
        defined?(Mongoid) and
        default.present?
      end

    private

      def default
        @default ||= if v5_or_later?
          Mongoid.clients['default']
        else
          Mongoid.sessions['default']
        end
      end

      def v5_or_later?
        Mongoid::VERSION >= '5.0'
      end
    end
  end
end
