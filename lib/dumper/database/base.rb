module Dumper
  module Database
    class Base
      include Dumper::Utility::ObjectFinder

      def initialize(stack)
        @stack = stack
      end
    end
  end
end
