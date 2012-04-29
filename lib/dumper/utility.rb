require 'ipaddr'

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
  end
end
