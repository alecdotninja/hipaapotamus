require 'active_record'

module Hipaapotamus
  class Action < ActiveRecord::Base
    self.table_name = 'hipaapotamus_actions'

    attr_accessor :source_transaction_state

    enum action_type: { access: 0, creation: 1, modification: 2, destruction: 3,
                        attempted_access: 4, attempted_creation: 5, attempted_modification: 6, attempted_destruction: 7 }

    def transactional?
      is_transactional
    end

    def log_worthy?
      persisted? || !transactional? || source_transaction_state.committed?
    end

    def agent_class
      agent_type.try(:constantize)
    end

    def agent
      if agent_class < Singleton
        agent_class.instance
      else
        agent_class.find(agent_id)
      end
    end

    def agent=(agent)
      if agent.is_a? Singleton
        self.agent_id = nil
      else
        self.agent_id = agent.id
      end

      self.agent_type = agent.class.name
    end

    def defended_class
      defended_type.try(:constantize)
    end

    def defended
      @defended ||= defended_class.new.tap do |defended|
        if defended_id.present?
          defended.id = defended_id
        end

        if defended_attributes.present?
          defended.assign_attributes defended_attributes
        end

        defended.authorize_access!
      end
    end

    def defended=(defended)
      self.defended_id = defended.try(:id)
      self.defended_type = defended.try(:class).try(:name)
      self.defended_attributes = defended.try(:attributes)

      @defended = defended
    end

    def defended_attributes
      JSON.parse(serialized_defended_attributes) if serialized_defended_attributes.present?
    end

    def defended_attributes=(defended_attributes)
      self.serialized_defended_attributes = defended_attributes.try(:to_json)
    end

    validate :not_changed
    validates :agent_type, :defended_type, :defended_attributes, :action_type, :performed_at, presence: true

    scope :with_defended, -> (defended) { where(defended_type: defended.class.name, defended_id: defended.id) }

    class << self
      def bulk_insert(actions)
        if actions.length > 0
          actions.each do |action|
            raise ActiveRecord::RecordInvalid, 'unable to modify existing actions' unless action.new_record?
            raise ActiveRecord::RecordInvalid, action.errors.full_messages.to_sentence unless action.valid?
          end

          attributeses = actions.map(&:attributes)

          now = DateTime.now
          attributeses.each { |attributes| attributes['created_at'] = now } if self.column_names.include?('created_at')
          attributeses.each { |attributes| attributes['updated_at'] = now } if self.column_names.include?('updated_at')

          uniq_keys = attributeses.map { |attributes| attributes.keys }.flatten(1).uniq.reject { |key| key == primary_key || key == primary_key.to_sym }

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
    end

    private

    def not_changed
      unless new_record?
        self.errors.add(:action, 'cannot be changed')
      end
    end
  end
end