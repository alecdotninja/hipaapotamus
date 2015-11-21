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
    end

    included do
      delegate :policy_class, :policy_class!, to: :class

      after_initialize do
        unless new_record?
          accountability_context = AccountabilityContext.current!

          policy_class!.authorize!(accountability_context.agent, self, :access)

          accountability_context.record_action(self, :access)
        end
      end

      after_create do
        accountability_context = AccountabilityContext.current!

        policy_class!.authorize!(accountability_context.agent, self, :creation)

        accountability_context.record_action(self, :creation)
      end

      after_update do
        accountability_context = AccountabilityContext.current!

        policy_class!.authorize!(accountability_context.agent, self, :modification)

        accountability_context.record_action(self, :modification)
      end

      after_destroy do
        unless new_record?
          accountability_context = AccountabilityContext.current!

          policy_class!.authorize!(accountability_context, self, :destruction)

          accountability_context.record_action(self, :destruction)
        end
      end
    end

    def hipaapotamus_display_name
      if new_record?
        "a new #{self.class.name}"
      else

        "#{self.class.name}(#{self.class.primary_key}=#{self[self.class.primary_key]})"
      end
    end
  end
end