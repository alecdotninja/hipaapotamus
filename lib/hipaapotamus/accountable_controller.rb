require 'active_support/concern'
require 'action_pack'
require 'rack/utils'

require 'hipaapotamus'
require 'hipaapotamus/accountability_error'

module Hipaapotamus
  module AccountableController
    extend ActiveSupport::Concern

    included do
      rescue_from AccountabilityError, with: :agent_not_authorized

      around_action :wrap_in_accountability_context

      helper_method :policy
      helper_method :access_path?
    end

    private

    def current_agent
      current_user
    end

    def wrap_in_accountability_context
      Hipaapotamus.with_accountability(current_agent) do
        yield
      end
    end

    def agent_not_authorized(accountability_error)
      render file: 'public/403', status: 403, formats: [:html], layout: false
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

          query_params = Rack::Utils.parse_query URI.parse(path).query
          route_params = Rails.application.routes.recognize_path path, options

          controller_class_name = "#{route_params[:controller].camelize}Controller"
          controller_class = controller_class_name.constantize
          controller = controller_class.new

          controller.params = ActionController::Parameters.new query_params.merge(route_params)

          controller.policy
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



