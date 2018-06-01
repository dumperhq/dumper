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

if Mongoid::VERSION >= '5.0'
  Mongoid.load!(Rails.root.join('config/mongoid5.yml'))
  # Mongoid::Clients.default # Trigger Mongoid::Clients::Factory.create(:default)
else
  Mongoid.load!(Rails.root.join('config/mongoid4.yml'))
  # Moped::Session.new(['localhost:27017'])
end

require 'redis'
$redis = Redis.new(db: 15)

require 'dumper'
