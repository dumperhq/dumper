module Dumper
  module Config
    class MongoDB < Base
      def initialize
        # @instance = instance || v5_or_later? ? first_instance_of('Mongo::Client') : first_instance_of('Moped::Session')
      end

      def exist?
        default.present?
      end

      def host
        default['hosts'].first.split(/:/)[0]
        # @instance.cluster.servers.first.address.host
      end

      def port
        default['hosts'].first.split(/:/)[1] || 27017
        # @instance.cluster.servers.first.address.port
      end

      def database
        # @instance.database.name
        default['database']
      end

      def username
        default['user']
      end

      def password
        default['password']
      end

      def dump_tool
        tool = 'mongodump'
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

    private

      def default
        if v5_or_later?
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
