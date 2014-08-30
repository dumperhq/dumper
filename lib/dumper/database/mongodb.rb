module Dumper
  module Database
    class MongoDB < Base
      DUMP_TOOL = 'mongodump'
      FORMAT = 'tar'

      def command
        "cd #{tmpdir} && #{dump_tool_path} #{connection_options} #{additional_options} #{custom_options} && tar -czf #{filename} --exclude='#{filename}' ."
      end

      def connection_options
        [ :database, :host, :port, :username, :password ].map do |option|
          next if @config[option].blank?
          "--#{option}='#{@config[option]}'".gsub('--database', '--db')
        end.compact.join(' ')
      end

      def additional_options
        "--out='#{tmpdir}'"
      end

      def set_config_for(rails_env=nil)
        return unless defined?(Mongo::DB) &&
          (mongo = find_instance_in_object_space(Mongo::DB)) ||
          defined?(Mongoid) && Mongoid::Config.respond_to?(:sessions) &&
          (mongoid = Mongoid::Config.sessions[:default])

        @config = {
          :host => mongo ? mongo.connection.host : mongoid[:hosts].first.split(/:/).first,
          :port => mongo ? mongo.connection.port : mongoid[:hosts].first.split(/:/).last,
          :database => mongo ? mongo.name : mongoid[:database],
          :dump_tool => dump_tool_path
        }.tap do |h|
          if auth = mongo ? mongo.connection.auths.first : mongoid
            h.update(:username => auth['username'], :password => auth['password'])
          end
        end
      end
    end
  end
end
