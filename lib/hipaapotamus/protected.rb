require 'hipaapotamus/accountability_error'

module Hipaapotamus
  module Protected
    extend ActiveSupport::Concern

    class_methods do
      def policy_class_name
        @policy_class_name ||= "#{name}Policy"
      end

      def policy_class
        @policy_class ||= policy_class_name.constantize
      end

      def policy_scoped
        policy_class.resolve_scope(AccountabilityContext.current_agent)
      end
    end

    included do
      delegate :policy_class, to: :class

      after_initialize :authorize_access!, unless: :new_record?
      after_create :authorize_creation!
      after_update :authorize_modification!
      after_destroy :authorize_destruction!
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
        policy_class.authorize!(accountability_context.agent, self, :access)

        accountability_context.record_action(self, :access)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_access)

        raise error
      end
    end

    def authorize_creation!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class.authorize!(accountability_context.agent, self, :creation)

        accountability_context.record_action(self, :creation, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_creation)

        raise error
      end
    end

    def authorize_modification!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class.authorize!(accountability_context.agent, self, :modification)

        accountability_context.record_action(self, :modification, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_modification)

        raise error
      end
    end

    def authorize_destruction!
      accountability_context = AccountabilityContext.current!

      begin
        policy_class.authorize!(accountability_context.agent, self, :destruction)

        accountability_context.record_action(self, :destruction, true)
      rescue AccountabilityError => error
        accountability_context.record_action(self, :attempted_destruction)

        raise error
      end
    end

    def permitted_attributes
      policy_class.permitted_attributes(AccountabilityContext.current!.agent, self)
    end

    protected

    def sanitize_for_mass_assignment(attributes)
      if attributes.respond_to?(:permitted?) && attributes.respond_to?(:permit) && (_permitted_attributes = permitted_attributes) != :permit_all_attributes
        super attributes.permit(_permitted_attributes).to_unsafe_hash
      else
        super attributes
      end
    end
  end
end
