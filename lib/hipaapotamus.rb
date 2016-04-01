require 'active_record'

require 'hipaapotamus/accountability_context'
require 'hipaapotamus/accountability_error'
require 'hipaapotamus/accountable_controller'
require 'hipaapotamus/action'
require 'hipaapotamus/agent'
require 'hipaapotamus/anonymous_agent'
require 'hipaapotamus/collection_policy'
require 'hipaapotamus/controller_policy'
require 'hipaapotamus/defended'
require 'hipaapotamus/defended_controller'
require 'hipaapotamus/defended_model'
require 'hipaapotamus/execution'
require 'hipaapotamus/logged_model'
require 'hipaapotamus/model_policy'
require 'hipaapotamus/policy'
require 'hipaapotamus/record_callback_proxy'
require 'hipaapotamus/static_policy'
require 'hipaapotamus/system_agent'
require 'hipaapotamus/version'

module Hipaapotamus
  class << self
    def transaction_manager
      ActiveRecord::Base.connection.transaction_manager
    end

    def root_transaction
      transaction_manager.instance_exec { @stack.try(:first) } || current_transaction
    end

    def current_transaction
      transaction_manager.current_transaction
    end

    def current_transaction_state
      current_transaction.try(:state)
    end

    def current_accountability_context
      AccountabilityContext.current
    end

    def current_agent
      current_accountability_context.try(:agent)
    end

    def with_accountability(agent, &block)
      agent = agent.instance if Class === agent && agent <= SystemAgent

      execution = nil
      accountability_context = AccountabilityContext.new(agent)

      is_using_callbacks = root_transaction.joinable?

      root_transaction.add_record RecordCallbackProxy.new accountability_context if is_using_callbacks

      accountability_context.within do
        execution = Execution.new(&block)
      end

      accountability_context.finalize! unless is_using_callbacks

      execution.try(:value)
    end

    def without_accountability(&block)
      with_accountability(AnonymousAgent.instance, &block)
    end

    def policy(target = self, options = nil)
      case target
        when Class
          defended_class = target

          if defended_class < Defended
            policy defended_class.new
          end
        when Defended
          defended = target

          unless options
            defended.class.policy(defended)
          end
        when Symbol
          route_name = target

          if Rails.application.routes.named_routes.get(route_name)
            request_options = options.extract!(:method)

            path = if options
                     public_send("#{route_name}_path", options)
                   else
                     public_send("#{route_name}_path")
                   end

            policy path, request_options
          end
        when Hash
          route_description = target
          options ||= {}

          request_options = target.extract!(:method)

          policy url_for(route_description), request_options.merge(options)
        when String
          path = target
          options ||= {}

          if defined?(Rails)
            query_params = Rack::Utils.parse_query URI.parse(path).query
            route_params = Rails.application.routes.recognize_path path, options

            controller_class_name = "#{route_params[:controller].camelize}Controller"
            controller_class = controller_class_name.constantize
            controller = controller_class.new

            controller.params = ActionController::Parameters.new query_params.merge(route_params)

            controller.policy
          end
      end
    end

    def access_path?(path, via = :get)
      _policy = policy(path, method: via)

      if _policy
        action = _policy.controller.params[:action]

        _policy.authorized?(action)
      else
        true
      end
    end
  end
end
