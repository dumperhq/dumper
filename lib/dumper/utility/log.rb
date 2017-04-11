require 'logger'

module Dumper
  module Utility
    module Log
      def logger
        @@logger ||= Dumper::Utility::SlimLogger.new("#{Rails.root}/log/dumper_agent.log", 1, 10.megabytes)
      end

      def stdout_logger
        @@stdout_logger ||= Dumper::Utility::SlimLogger.new(STDOUT)
      end

      def log(msg, level=:info)
        stdout_logger.send level, "** [Dumper] " + msg
        return unless true #should_log?
        logger.send level, msg
      end

      def log_last_error
        log [ $!.class.name, $!.to_s ].join(', ')
        log ("\n" << $!.backtrace.join("\n")), :debug
      end
    end

    class SlimLogger < Logger
      def initialize(logdev, shift_age = 0, shift_size = 1048576)
        super
        self.formatter = SlimFormatter.new
        self.formatter.datetime_format = "%Y-%m-%dT%H:%M:%S"
        self.level = Logger::INFO
      end
      
      class SlimFormatter < Logger::Formatter
        # This method is invoked when a log event occurs
        def call(severity, time, progname, msg)
          "[%s (%d)] %5s : %s\n" % [format_datetime(time), $$, severity, msg2str(msg)]
        end
      end
    end
  end
end
