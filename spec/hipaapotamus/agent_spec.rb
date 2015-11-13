require 'spec_helper'

describe Hipaapotamus::AnonymousAgent do
  let(:agent) { User.create! }

  describe '#with_accountability' do
    it 'evaluates a block in an AccountabilityContext with the agent' do
      agent.with_accountability do
        expect(Hipaapotamus::AccountabilityContext.current.agent).to eq agent
      end
    end
  end

  describe '#hipaapotamus_display_name' do
    it 'returns a string' do
      expect(agent.hipaapotamus_display_name).to be_a String
    end
  end
end