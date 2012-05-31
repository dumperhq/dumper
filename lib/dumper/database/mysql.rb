module Dumper
  module Database
    class MySQL < Base
      DUMP_TOOL = 'mysqldump'
      FILE_EXT = 'sql.gz'

      def command
        "#{@stack.configs[:mysql][:dump_tool]} #{connection_options} #{additional_options} #{@stack.configs[:mysql][:database]} | gzip > #{@tempfile.path}"
      end

      def connection_options
        [ :host, :port, :username, :password ].map do |option|
          next if @stack.configs[:mysql][option].blank?
          "--#{option}='#{@stack.configs[:mysql][option]}'".gsub('--username', '--user')
        end.compact.join(' ')
      end

      def additional_options
        '--single-transaction'
      end

      def config_for(rails_env=nil)
        return unless defined?(ActiveRecord::Base) &&
          ActiveRecord::Base.configurations &&
          (config = ActiveRecord::Base.configurations[rails_env]) &&
          %w(mysql mysql2).include?(config['adapter'])

        {
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
