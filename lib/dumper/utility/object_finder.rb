module Dumper
  module Utility
    module ObjectFinder
      def find_instance_in_object_space(klass)
        ObjectSpace.each_object(klass).first
      end
    end
  end
end
