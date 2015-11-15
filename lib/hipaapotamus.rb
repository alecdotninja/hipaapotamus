require 'active_record'
require 'hipaapotamus/accountability_error'
require 'hipaapotamus/accountability_context'
require 'hipaapotamus/agent'
require 'hipaapotamus/policy'
require 'hipaapotamus/action'
require 'hipaapotamus/protected'
require 'hipaapotamus/system_agent'
require 'hipaapotamus/anonymous_agent'
require 'hipaapotamus/version'

module Hipaapotamus
  class << self
    def current_accountability_context
      AccountabilityContext.current
    end

    def current_agent
      current_accountability_context.try(:agent)
    end

    def with_accountability(agent)
      return_value = nil
      raise_value = nil
      commits = false

      ActiveRecord::Base.transaction do
        accountability_context = AccountabilityContext.new(agent) do
          ActiveRecord::Base.transaction do
            begin
              return_value = yield
              commits = true
            rescue ActiveRecord::Rollback
              raise ActiveRecord::Rollback
            rescue Exception => e
              raise_value = e
              raise ActiveRecord::Rollback
            end
          end
        end

        action_attributes = []

        accountability_context.actions.each do |action|
          action_attributes << {
            agent_id: agent.try(:id),
            agent_type: agent.class.name,
            protected_id: action[:protected_id],
            protected_type: action[:protected_type],
            protected_attributes: action[:protected_attributes].to_json,

            action_type: Action.action_types[
              if action[:action_type] == :create
                'create'
              else
                if commits
                  "committed_#{action[:action_type]}"
                else
                  "reverted_#{action[:action_type]}"
                end
              end
            ],
            performed_at: action[:performed_at]
          }
        end

        if action_attributes.count > 0
          Action.bulk_insert(action_attributes)
        end
      end

      raise raise_value if raise_value
      return_value
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end
  end
end
