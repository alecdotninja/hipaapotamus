require 'active_support/concern'

module Hipaapotamus
  module AccountableController
    extend ActiveSupport::Concern

    included do
      around_action :wrap_in_accountability_context
      rescue_from AccountabilityError, with: :agent_not_authorized
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
      render text: accountability_error.to_s, status: 401
    end
  end
end
