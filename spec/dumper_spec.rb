require 'spec_helper'

require 'rails'

describe Dumper do
  it 'conforms to public API' do
    expect(Dumper::Agent.respond_to?(:start)).to be_truthy
  end

  it 'loads everything' do
    expect {
      Dumper::Agent
      # Dumper::Cli
      Dumper::Dependency
      Dumper::Job
      Dumper::Stack
      Dumper::Utility
      Dumper::VERSION
      Dumper::Database::Base
      Dumper::Database::MySQL
      Dumper::Database::PostgreSQL
      Dumper::Database::MongoDB
      Dumper::Database::Redis
    }.to_not raise_error
  end

  describe :Stack do
    it 'initializes stack' do
      stack = Dumper::Stack.new
      expect(stack.framework).to eq(:rails)
      expect(stack.rails_env).to eq('development')
    end

    it 'detects mongoid' do
      require 'mongoid'
      Mongoid::Config.send :load_configuration, { sessions: { default: { hosts: ['localhost:27017'], database: 'test' } } }

      stack = Dumper::Stack.new
      expect(stack.databases[:mongodb]).not_to eq(nil)
    end

    it 'detects mongo_mapper' do
      require 'mongo_mapper'
      MongoMapper.setup({ development: { database: 'test' } }, :development)
      MongoMapper.database

      stack = Dumper::Stack.new
      expect(stack.databases[:mongodb]).not_to eq(nil)
    end

    it 'detects mysql' do
      require 'active_record'
      ActiveRecord::Base.configurations['development'] = { 'adapter' => 'mysql2' }

      stack = Dumper::Stack.new
      expect(stack.databases[:mysql]).not_to eq(nil)
    end

    it 'detects postgresql' do
      require 'active_record'
      ActiveRecord::Base.configurations['development'] = { 'adapter' => 'postgresql' }

      stack = Dumper::Stack.new
      expect(stack.databases[:postgresql]).not_to eq(nil)
    end

    it 'detects redis' do
      require 'redis'
      redis = Redis.new

      stack = Dumper::Stack.new
      expect(stack.databases[:redis]).not_to eq(nil)
    end
  end
end
