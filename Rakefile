#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'appraisal'

# RSpec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

if !ENV['APPRAISAL_INITIALIZED'] && !ENV['TRAVIS']
  task :default => :appraisal
else
  task :default => :spec
end

desc 'Setup test MongoDB database and user'
task :setup_mongo do
  puts `mongo spec/config/mongo_setup.js`
end
