require 'rubygems'
require 'bundler/setup'

ENV['TEST_MODE'] = 'true' # Silence bson_ext warning.
ENV['RAILS_ENV'] = 'test'

require 'rails/all'
require 'mongoid'  # Kludge

case Rails::VERSION::MAJOR
when 3
  require_relative 'apps/rails3'
when 4
  require_relative 'apps/rails4'
when 5
  require_relative 'apps/rails5'
end

require 'dumper'
