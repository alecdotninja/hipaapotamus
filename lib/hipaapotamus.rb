require 'active_record'
require 'hipaapotamus/accountability_error'
require 'hipaapotamus/accountability_context'
require 'hipaapotamus/execution'
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
      executiton = nil

      ActiveRecord::Base.transaction(requires_new: true) do
        accountability_context = AccountabilityContext.new(agent) do
          ActiveRecord::Base.transaction(requires_new: true) do
            executiton = Execution.new do
              yield
            end

            raise ActiveRecord::Rollback if executiton.raised?
          end
        end

        Action.bulk_insert(
          accountability_context.actions.map do |action|
            {
              agent_id: agent.try(:id),
              agent_type: agent.class.name,
              protected_id: action[:protected_id],
              protected_type: action[:protected_type],
              protected_attributes: action[:protected_attributes].to_json,

              action_type: Action.action_types[
                if action[:action_type] == :create
                  'create'
                else
                  if executiton.raised?
                    "committed_#{action[:action_type]}"
                  else
                    "reverted_#{action[:action_type]}"
                  end
                end
              ],
              performed_at: action[:performed_at]
            }
          end
        )
      end

      executiton.try(:value)
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end
  end
end
