require 'spec_helper'

describe Hipaapotamus do
  it 'has a version number' do
    expect(Hipaapotamus::VERSION).not_to be nil
  end

  describe '.current_accountability_context' do
    it 'delegates to Hipaapotamus::AccountabilityContext.current' do
      expect(Hipaapotamus::AccountabilityContext).to receive(:current)

      Hipaapotamus.current_accountability_context
    end
  end

  describe '.current_agent' do
    it 'delegates to .current_accountability_context.agent' do
      expect(Hipaapotamus).to receive(:current_accountability_context)

      Hipaapotamus.current_agent
    end
  end
end
