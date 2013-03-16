require 'spec_helper'

require 'rails'

describe Dumper do
  it 'conforms to public API' do
    Dumper::Agent.respond_to?(:start).should be_true
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
      stack.framework.should == :rails
      stack.rails_env.should == 'development'
    end

    it 'detects mongoid 3' do
      require 'mongoid'
      Mongoid::Config.send :load_configuration, { sessions: { default: { hosts: ['localhost:27017'], database: 'test' } } }

      stack = Dumper::Stack.new
      stack.databases[:mongodb].should_not == nil
    end

    it 'detects mongo_mapper' do
      require 'mongo_mapper'
      MongoMapper.setup({ development: { database: 'test' } }, :development)
      MongoMapper.database

      stack = Dumper::Stack.new
      stack.databases[:mongodb].should_not == nil
    end

    it 'detects mysql' do
      require 'active_record'
      ActiveRecord::Base.configurations['development'] = { 'adapter' => 'mysql2' }

      stack = Dumper::Stack.new
      stack.databases[:mysql].should_not == nil
    end

    it 'detects postgresql' do
      require 'active_record'
      ActiveRecord::Base.configurations['development'] = { 'adapter' => 'postgresql' }

      stack = Dumper::Stack.new
      stack.databases[:postgresql].should_not == nil
    end

    it 'detects redis' do
      require 'redis'
      redis = Redis.new

      stack = Dumper::Stack.new
      stack.databases[:redis].should_not == nil
    end
  end
end
