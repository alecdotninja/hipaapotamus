require 'active_record'

module Hipaapotamus
  class RecordCallbackProxy
    attr_reader :accountability_context

    def initialize(accountability_context)
      @accountability_context = accountability_context
    end

    def rolledback!(*args)
      accountability_context.finalize!
    end

    def before_committed!(*args)
      # NOOP
    end

    def committed!(*args)
      accountability_context.finalize!
    end

    def add_to_transaction
      ActiveRecord::Base.connection.add_transaction_record(self)
    end
  end
end