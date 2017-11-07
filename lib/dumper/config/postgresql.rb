module Dumper
  module Config
    class PostgreSQL < Base
      def initialize(additional_env: nil)
        @rails_env = additional_env || Rails.env

        return unless exist?

        @host = @config['host']
        @port = @config['port']
        @database = @config['database']
        @username = @config['username']
        @password = @config['password']
      end

      def exist?
        defined?(ActiveRecord::Base) and
        ActiveRecord::Base.configurations and
        @config = ActiveRecord::Base.configurations[@rails_env] and
        @config['adapter'] == 'postgresql'
      end
    end
  end
end
