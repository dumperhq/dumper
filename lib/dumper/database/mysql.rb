module Dumper
  module Database
    class MySQL < Base
      def command
        "mysqldump #{connection_options} #{additional_options} #{@stack.activerecord_config['database']} | gzip"
      end

      protected

      def connection_options
        [ :host, :port, :username, :password ].map do |option|
          next if @stack.activerecord_config[option.to_s].blank?
          "--#{option}='#{@stack.activerecord_config[option.to_s]}'".gsub('--username', '--user')
        end.compact.join(' ')
      end

      def additional_options
        '--single-transaction'
      end
    end
  end
end
