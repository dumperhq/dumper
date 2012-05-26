require 'spec_helper'

describe Dumper do
  it 'initializes' do
    Dumper::Agent.respond_to?(:start).should be_true
  end
end
