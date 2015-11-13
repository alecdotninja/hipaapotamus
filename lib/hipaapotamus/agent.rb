require 'active_support/concern'
require 'hipaapotamus/accountability_context'

module Hipaapotamus
  module Agent
    extend ActiveSupport::Concern

    def with_accountability(&block)
      Hipaapotamus.with_accountability(self, &block)
    end

    def hipaapotamus_display_name
      'This agent'
    end
  end
end