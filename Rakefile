require "bundler/setup"
require "hipaapotamus"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

task :console do
  require 'pry'
  Pry.start
end
