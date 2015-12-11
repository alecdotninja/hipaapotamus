require 'active_support/concern'

module Hipaapotamus
  module AccountableController
    extend ActiveSupport::Concern

    included do
      around_action :wrap_in_accountability_context
    end

    private

    def wrap_in_accountability_context
      Hipaapotamus.with_accountability(current_agent) do
        yield
      end
    end

    def current_agent
      current_user
    end
  end
end
