require 'active_support/concern'
require 'hipaapotamus/accountability_context'

module Hipaapotamus
  module Agent
    extend ActiveSupport::Concern

    def with_accountability(&block)
      AccountabilityContext.new(self, &block)
    end
  end
end