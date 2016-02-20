require 'active_support/concern'

require 'hipaapotamus/defended_model'

module Hipaapotamus
  module LoggedModel
    extend ActiveSupport::Concern

    include DefendedModel

    def authorize_access!
      accountability_context = AccountabilityContext.current!

      begin
        super

        accountability_context.record_action(self, :access)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_access)

        raise error
      end
    end

    def authorize_creation!
      accountability_context = AccountabilityContext.current!

      begin
        super

        accountability_context.record_action(self, :creation, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_creation)

        raise error
      end
    end

    def authorize_modification!
      accountability_context = AccountabilityContext.current!

      begin
        super

        accountability_context.record_action(self, :modification, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_modification)

        raise error
      end
    end

    def authorize_destruction!
      accountability_context = AccountabilityContext.current!

      begin
        super

        accountability_context.record_action(self, :destruction, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_destruction)

        raise error
      end
    end
  end
end
