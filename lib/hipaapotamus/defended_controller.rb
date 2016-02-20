require 'active_support/concern'

require 'hipaapotamus/accountable_controller'
require 'hipaapotamus/defended'

module Hipaapotamus
  module DefendedController
    extend ActiveSupport::Concern

    include AccountableController
    include Defended

    included do
      before_action :authorize_action!
    end

    private

    def authorize_action!
      policy.authorize! action_name
    end
  end
end