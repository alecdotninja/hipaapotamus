require 'rails/generators'
require 'rails/generators/active_record'

module Hipaapotamus
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    source_root File.expand_path('../templates', __FILE__)

    def create_migration_file
      migration_template 'create_hipaapotamus_actions.rb', 'db/migrate/create_hipaapotamus_actions.rb'
    end
  end
end