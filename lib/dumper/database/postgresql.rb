module Dumper
  module Database
    class PostgreSQL < Base
      DUMP_TOOL = 'pg_dump'
      FORMAT = 'sql'

      def command
        "cd #{tmpdir} && #{password_variable} #{dump_tool_path} #{connection_options} #{custom_options} #{@config[:database]} | gzip > #{filename}"
      end

      def connection_options
        [ :host, :port, :socket, :username ].map do |option|
          next if @config[option].blank?
          "--#{option}='#{@config[option]}'".gsub('--socket', '--host')
        end.compact.join(' ')
      end

      def password_variable
        @config[:password].blank? ? '' : "PGPASSWORD='#{@config[:password]}'"
      end

      def set_config_for(rails_env=nil)
        return unless defined?(ActiveRecord::Base) &&
          ActiveRecord::Base.configurations &&
          (config = ActiveRecord::Base.configurations[rails_env]) &&
          (config['adapter'] == 'postgresql')

        @config = {
          :host => config['host'],
          :port => config['port'],
          :username => config['username'],
          :password => config['password'],
          :database => config['database'],
          :dump_tool => dump_tool_path
        }
      end
    end
  end
end
