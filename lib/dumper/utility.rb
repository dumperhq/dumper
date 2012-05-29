require 'ipaddr'
require 'logger'

module Dumper
  module Utility
    class IP
      attr_reader :ip, :ipaddr

      def initialize(*args)
        disable_reverse_lookup do
          UDPSocket.open do |s|
            s.connect '64.233.187.99', 1
            @ip = s.addr.last
          end
        end
        @ipaddr = Dumper::Utility::IPAddr.new(@ip)
      end

      def disable_reverse_lookup
        orig = Socket.do_not_reverse_lookup
        Socket.do_not_reverse_lookup = true
        begin
          yield
        ensure
          Socket.do_not_reverse_lookup = orig
        end
      end
    end

    class IPAddr < ::IPAddr
      def private?
        return false unless self.ipv4?

        [ IPAddr.new("10.0.0.0/8"),
          IPAddr.new("172.16.0.0/12"),
          IPAddr.new("192.168.0.0/16") ].any?{|i| i.include? self }
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
          "[%s] %5s : %s\n" % [format_datetime(time), severity, msg2str(msg)]
        end
      end
    end

    module LoggingMethods
      def logger
        @logger ||= Dumper::Utility::SlimLogger.new("#{Rails.root}/log/dumper_agent.log", 1, 10.megabytes)
      end

      def stdout_logger
        @stdout_logger ||= Dumper::Utility::SlimLogger.new(STDOUT)
      end

      def log(msg, level=:info)
        stdout_logger.send level, "** [Dumper] " + msg
        return unless true #should_log?
        logger.send level, msg
      end

      def log_last_error
        log [ $!.class.name, $!.to_s ].join(', ')
      end
    end
  end
end
