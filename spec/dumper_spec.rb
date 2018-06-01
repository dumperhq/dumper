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
      # Dumper::Dependency
      Dumper::Job
      Dumper::Stack
      Dumper::Utility
      Dumper::VERSION
      Dumper::Config::Base
      Dumper::Config::MySQL
      Dumper::Config::PostgreSQL
      Dumper::Config::MongoDB
      Dumper::Config::Redis
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
      expect(Rails.env).to eq('test')
    end

    it 'detects mongoid' do
      stack = Dumper::Stack.new
      expect(stack.databases[:mongodb]).not_to eq(nil)
      expect(stack.databases[:mongodb].config).to be_present
    end

    it 'detects mysql' do
      require 'active_record'
      ActiveRecord::Base.configurations.clear
      ActiveRecord::Base.configurations['test'] = { 'adapter' => 'mysql2' }

      stack = Dumper::Stack.new
      expect(stack.databases[:mysql]).not_to eq(nil)
      expect(stack.databases[:mysql].config).to be_present
    end

    it 'detects postgresql' do
      require 'active_record'
      ActiveRecord::Base.configurations.clear
      ActiveRecord::Base.configurations['test'] = { 'adapter' => 'postgresql' }

      stack = Dumper::Stack.new
      expect(stack.databases[:postgresql]).not_to eq(nil)
      expect(stack.databases[:postgresql].config).to be_present
    end

    it 'detects additional env' do
      require 'active_record'
      ActiveRecord::Base.configurations.clear
      ActiveRecord::Base.configurations['more_development'] = { 'adapter' => 'postgresql' }

      stack = Dumper::Stack.new(additional_env: 'more_development')
      expect(stack.databases[:postgresql]).not_to eq(nil)
      expect(stack.databases[:postgresql].config).to be_present
    end

    it 'detects redis' do
      stack = Dumper::Stack.new
      expect(stack.databases[:redis]).not_to eq(nil)
      expect(stack.databases[:redis].config).to be_present
    end
  end
end
