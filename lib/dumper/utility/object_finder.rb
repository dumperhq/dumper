module Dumper
  module Utility
    module ObjectFinder
      def has_instance_of?(name)
        !!first_instance_of(name)
      end

      def first_instance_of(name)
        return unless Object.const_defined?(name)

        ObjectSpace.each_object(Object.const_get(name)).first
      end
    end
  end
end
