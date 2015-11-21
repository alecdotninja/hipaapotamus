require "bundler/setup"
require "hipaapotamus"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)
task spec: :test

task :console do
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  ActiveRecord::Base.connection.execute 'CREATE TABLE hipaapotamus_actions (id integer PRIMARY KEY NOT NULL, agent_id integer, agent_type character varying NOT NULL, protected_id integer, protected_type character varying NOT NULL, serialized_protected_attributes text NOT NULL, action_type integer NOT NULL, action_completed boolean NOT NULL, performed_at timestamp without time zone NOT NULL, created_at timestamp without time zone NOT NULL);'

  require 'pry'
  Hipaapotamus.pry
end

# For travis
task default: :test
