require 'logger'

module Dumper
  module Utility
    module Log
      def logger
        @@logger ||= Dumper::Utility::MultiLogger.new
      end

      def log(msg, level=:info)
        logger.send level, msg
      end

      def log_last_error
        log [ $!.class.name, $!.to_s ].join(', ')
        log ("\n" << $!.backtrace.join("\n")), :debug
      end
    end

    class MultiLogger
      attr_reader :stdout, :file

      def initialize
        @stdout = Logger.new(STDOUT)
        @stdout.formatter = proc do |_, _, _, msg|
          "** [Dumper] #{msg}\n"
        end

        @file = Logger.new("#{Rails.root}/log/dumper_agent.log", 1, 10.megabytes)
        @file.formatter = proc do |severity, time, _, msg|
          timestamp = time.strftime "%Y-%m-%dT%H:%M:%S"
          "[#{timestamp} (#{$$})] #{severity} : #{msg}\n"
        end

        @loggers = [@stdout, @file]
      end

      def method_missing(*args, &blk)
        @loggers.each {|logger| logger.send(*args, &blk) }
      end

      def respond_to_missing?(*args)
        @loggers.all? {|logger| logger.respond_to?(*args) }
      end
    end
  end
end
