require 'spec_helper'

describe Hipaapotamus::Agent do
  let(:agent) { User.create! }

  describe '#with_accountability' do
    it 'evaluates a block in an AccountabilityContext with the agent' do
      agent.with_accountability do
        expect(Hipaapotamus::AccountabilityContext.current.agent).to eq agent
      end
    end
  end
end