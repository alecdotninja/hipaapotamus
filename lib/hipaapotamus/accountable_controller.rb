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

      helper_method :authorized?
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

    # authorized?(:new_trucks, a: 7, method: 'GET')
    # authorized?(trucks_path(a: 7, b: 9), method: 'GET')

    def authorized?(path, options = {})
      request_options = options.extract!(:method)

      path = public_send("#{path}_path", options) if Rails.application.routes.named_routes.get(path)
      path = url_for(path) unless String === path

      query_params = Rack::Utils.parse_query URI.parse(path).query

      route_params = Rails.application.routes.recognize_path path, request_options
      controller_class_name = "#{route_params[:controller].camelize}Controller"
      action_name = route_params[:action]

      controller_class = controller_class_name.constantize
      controller = controller_class.new
      controller.params = ActionController::Parameters.new query_params.merge(route_params)

      policy = controller.policy

      policy.authorized? action_name
    end
  end
end



