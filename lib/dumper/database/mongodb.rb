module Dumper
  module Database
    class MongoDB < Base
      DUMP_TOOL = 'mongodump'
      FILE_EXT = 'tar.gz'

      def command
        "cd #{tmpdir} && #{dump_tool_path} #{connection_options} #{additional_options} && tar -czf #{filename} --exclude='#{filename}' ."
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
          (mongo = find_instance_in_object_space(Mongo::DB))

        @config = {
          :host => mongo.connection.host,
          :port => mongo.connection.port,
          :database => mongo.name,
          :dump_tool => dump_tool_path
        }.tap do |h|
          if auth = mongo.connection.auths.first
            h.update(:username => auth['username'], :password => auth['password'])
          end
        end
      end
    end
  end
end
