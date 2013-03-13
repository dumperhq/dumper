require 'rubygems'
require 'bundler/setup'

require 'dumper'

RSpec.configure do |config|
  ENV['TEST_MODE'] = 'true' # Silence bson_ext warning.
end
