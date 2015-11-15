require 'active_record'

module Hipaapotamus
  class Action < ActiveRecord::Base
    self.table_name = 'hipaapotamus_actions'

    belongs_to :agent, polymorphic: true
    belongs_to :protected, polymorphic: true

    enum action_type: {
      access: 0, committed_create: 1, committed_update: 2, committed_destroy: 3,
      attempted_access: 4, attempted_create: 5, attempted_update: 6, attempted_destroy: 7,
      reverted_update: 8, reverted_create: 9, reverted_destroy: 10
    }

    validate :not_changed

    class << self
      def bulk_insert(attributeses)
        now = DateTime.now

        attributeses.each { |attributes| attributes[:created_at] = now } if self.column_names.include?('created_at')
        attributeses.each { |attributes| attributes[:updated_at] = now } if self.column_names.include?('updated_at')

        uniq_keys = attributeses.map { |attributes| attributes.keys }.flatten(1).uniq

        column_names = uniq_keys.map(&:to_s)
        rows = attributeses.map { |attributes| uniq_keys.map { |key| attributes[key] } }

        value_template = "(#{column_names.map{'?'}.join(', ')})"

        value_clauses = rows.map { |values| sanitize_sql_array([value_template, *values]) }
        values_clause = value_clauses.join(', ')

        column_clauses = column_names.map { |column_name| connection.quote_column_name(column_name) }
        columns_clause = "#{connection.quote_column_name(table_name)} (#{column_clauses.join(', ')})"

        insert_statement = "INSERT INTO #{columns_clause} VALUES #{values_clause};"

        connection.execute(insert_statement)
      end
    end

    private

    def not_changed
      unless new_record?
        self.errors.add(:action, 'cannot be changed')
      end
    end
  end
end