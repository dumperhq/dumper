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

      def set_config
        config = Dumper::Config::MongoDB.new
        return unless config.exist?

        @config = {
          :host => config.host,
          :port => config.port,
          :database => config.database,
          :dump_tool => config.dump_tool
        }.tap do |h|
          h[:username] = config.username if config.username
          h[:password] = config.password if config.password
        end
      end
    end
  end
end
