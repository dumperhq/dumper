require 'multi_json'

# multi_json changed its API at 1.3 and older versions don't have dump/load methods.
# We backport those methods when older versions are detected.
#
unless MultiJson.respond_to?(:dump)
  module MultiJson
    module_function

    def dump(object)
      MultiJson.encode(object)
    end

    def load(string)
      MultiJson.decode(string)
    end
  end
end
