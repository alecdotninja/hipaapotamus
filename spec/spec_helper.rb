$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'hipaapotamus'
require 'active_record'
require 'action_controller'
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Base.connection.execute 'CREATE TABLE hipaapotamus_actions (id integer PRIMARY KEY NOT NULL, agent_id integer, agent_type character varying NOT NULL, protected_id integer, protected_type character varying NOT NULL, serialized_protected_attributes text NOT NULL, action_type integer NOT NULL, is_transactional boolean NOT NULL, performed_at timestamp without time zone NOT NULL, created_at timestamp without time zone NOT NULL);'

ActiveRecord::Base.connection.execute 'CREATE TABLE "users" ("id" INTEGER PRIMARY KEY)'
class User < ActiveRecord::Base
  include Hipaapotamus::Agent
end

ActiveRecord::Base.connection.execute 'CREATE TABLE "medical_secrets" ("id" INTEGER PRIMARY KEY)'
class MedicalSecret < ActiveRecord::Base
  include Hipaapotamus::Protected
end

class MedicalSecretPolicy < Hipaapotamus::Policy
  def access?
    medical_secret.present?
  end

  def creation?
    true
  end

  def modification?
    true
  end

  def destruction?
    true
  end

  def self.scope(agent)
    MedicalSecret.all
  end
end

ActiveRecord::Base.connection.execute 'CREATE TABLE "patient_secrets" ("id" INTEGER PRIMARY KEY, serial_number character varying)'
class PatientSecret < ActiveRecord::Base
  include Hipaapotamus::Protected
end

class PatientSecretPolicy < Hipaapotamus::Policy
  def access?
    false
  end

  def creation?
    false
  end

  def modification?
    false
  end

  def destruction?
    false
  end

  def self.scope(agent)
    PatientSecret.where(PatientSecret.arel_table[:serial_number].not_eq('out of scope').or(PatientSecret.arel_table[:serial_number].eq(nil)))
  end
end

ActiveRecord::Base.connection.execute 'CREATE TABLE "untainteds" ("id" INTEGER PRIMARY KEY)'
class Untainted < ActiveRecord::Base
  include Hipaapotamus::Protected
end

class UntaintedPolicy < Hipaapotamus::Policy
end

ActiveRecord::Base.connection.execute 'CREATE TABLE "policyless_models" ("id" INTEGER PRIMARY KEY)'
class PolicylessModel < ActiveRecord::Base
end
