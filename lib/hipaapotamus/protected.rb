require 'hipaapotamus/accountability_error'

module Hipaapotamus
  module Protected
    extend ActiveSupport::Concern

    class_methods do
      def policy_class_name
        @policy_class_name ||= "#{name}Policy"
      end

      def policy_class
        if policy_class_name
          @policy_class ||= policy_class_name.constantize
        end
      end

      def policy_class!
        policy_class || raise(AccountabilityError, "Could not find the policy class for #{name}")
      end

      def policy_scoped
        policy_class!.scope(AccountabilityContext.current_agent) || none
      end
    end

    included do
      delegate :policy_class, :policy_class!, to: :class

      after_initialize :authorize_access!, unless: :new_record?
      after_create :authorize_creation!
      after_update :authorize_modification!
      after_destroy :authorize_destruction!

      # default_scope { policy_scope }
    end

    def hipaapotamus_display_name
      if new_record?
        "a new #{self.class.name}"
      else

        "#{self.class.name}(#{self.class.primary_key}=#{self[self.class.primary_key]})"
      end
    end

    def authorize_access!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class!.authorize!(accountability_context.agent, self, :access)

        accountability_context.record_action(self, :access)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_access)

        raise error
      end
    end

    def authorize_creation!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class!.authorize!(accountability_context.agent, self, :creation)

        accountability_context.record_action(self, :creation, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_creation)

        raise error
      end
    end

    def authorize_modification!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class!.authorize!(accountability_context.agent, self, :modification)

        accountability_context.record_action(self, :modification, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_modification)

        raise error
      end
    end

    def authorize_destruction!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class!.authorize!(accountability_context.agent, self, :destruction)

        accountability_context.record_action(self, :destruction, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_destruction)

        raise error
      end
    end
  end
end