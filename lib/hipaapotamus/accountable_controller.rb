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
  end
end



