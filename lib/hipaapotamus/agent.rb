require 'active_support/concern'

require 'hipaapotamus'

module Hipaapotamus
  module Agent
    extend ActiveSupport::Concern

    def with_accountability(&block)
      Hipaapotamus.with_accountability(self, &block)
    end
  end
end