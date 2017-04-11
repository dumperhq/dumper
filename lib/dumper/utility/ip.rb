Dumper::Dependency.load('ipaddress')
require 'forwardable'

module Dumper
  module Utility
    class IP
      extend Forwardable
      def_delegators :@ip, :address, :private?

      def initialize(*args)
        UDPSocket.open do |s|
          s.do_not_reverse_lookup = true
          s.connect '64.233.187.99', 1
          @ip = IPAddress(s.addr.last)
        end
        raise "#{@ip.address} is not IPv4!" unless @ip.ipv4?
      end
    end
  end
end
