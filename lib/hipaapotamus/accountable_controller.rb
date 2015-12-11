require 'active_support/concern'

module Hipaapotamus
  module Accountable
    extend ActiveSupport::Concern

    included do
      around_action do
        Hipaapotamus.with_accountability(current_agent) do
          yield
        end
      end
    end

    def current_agent
      current_user
    end
  end
end
