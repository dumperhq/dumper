module Dumper
  module Database
    class MySQL < Base
      DUMP_TOOL = 'mysqldump'
      FORMAT = 'sql'

      def command
        "cd #{tmpdir} && #{dump_tool_path} #{connection_options} #{additional_options} #{custom_options} #{@config[:database]} | gzip > #{filename}"
      end

      def connection_options
        [ :host, :port, :username, :password ].map do |option|
          next if @config[option].blank?
          "--#{option}='#{@config[option]}'".gsub('--username', '--user')
        end.compact.join(' ')
      end

      def additional_options
        '--single-transaction'
      end

      def set_config_for(rails_env=nil)
        return unless defined?(ActiveRecord::Base) &&
          ActiveRecord::Base.configurations &&
          (config = ActiveRecord::Base.configurations[rails_env]) &&
          %w(mysql mysql2 mysql2spatial).include?(config['adapter'])

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
