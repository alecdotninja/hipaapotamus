require 'active_record'

module Hipaapotamus
  class Action < ActiveRecord::Base
    FROM_ACTION_TYPES = {
      access: 0, create: 1, update: 2, destroy: 3,
      attempted_access: 4, attempted_create: 5, attempted_update: 6, attempted_destroy: 7,
      reverted_update: 8, reverted_create: 9, reverted_destroy: 10
    }.with_indifferent_access.freeze

    TO_ACTION_TYPES = FROM_ACTION_TYPES.invert.freeze

    belongs_to :agent, polymorphic: true
    belongs_to :protected, polymorphic: true

    validate :not_changed

    private

    def not_changed
      unless new_record?
        self.errors.add(:action, 'cannot be changed')
      end
    end
  end
end