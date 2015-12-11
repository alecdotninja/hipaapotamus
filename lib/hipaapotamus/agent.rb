require 'active_support/concern'
require 'hipaapotamus/accountability_context'

module Hipaapotamus
  module Agent
    extend ActiveSupport::Concern

    def with_accountability(&block)
      Hipaapotamus.with_accountability(self, &block)
    end

    def hipaapotamus_display_name
      "#{self.class.name}(id=#{id})" rescue self.class.name
    end
  end
end