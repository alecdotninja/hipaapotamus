$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hipaapotamus'
require 'active_record'
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

ActiveRecord::Base.connection.execute 'CREATE TABLE "users" ("id" INTEGER PRIMARY KEY)'
class User < ActiveRecord::Base
  include Hipaapotamus::Agent
end

class MedicalSecretPolicy < Hipaapotamus::Policy
end

ActiveRecord::Base.connection.execute 'CREATE TABLE "medical_secrets" ("id" INTEGER PRIMARY KEY)'
class MedicalSecret < ActiveRecord::Base
  include Hipaapotamus::Protected
end
