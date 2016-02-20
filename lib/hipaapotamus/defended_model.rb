require 'active_support/concern'

require 'hipaapotamus/defended'

module Hipaapotamus
  module DefendedModel
    extend ActiveSupport::Concern

    include Defended

    class_methods do
      def policy_scoped
        collection_policy.resolve_scope
      end
    end

    included do
      after_initialize :authorize_access!, unless: :new_record?
      after_create :authorize_creation!
      after_update :authorize_modification!
      after_destroy :authorize_destruction!
    end

    def authorize_access!
      policy.authorize!(:access)
    end

    def authorize_creation!
      policy.authorize!(:creation)
    end

    def authorize_modification!
      policy.authorize!(:modification)
    end

    def authorize_destruction!
      policy.authorize!(:destruction)
    end

    def permitted_attributes
      policy.permitted_attributes
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
