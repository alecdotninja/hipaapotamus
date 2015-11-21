require 'spec_helper'

describe Hipaapotamus::Policy do
  let(:agent) { User.create! }
  let(:protected) { Hipaapotamus.without_accountability { MedicalSecret.create! } }
  let(:policy) { Hipaapotamus::Policy.new(agent, protected) }

  context 'by default (unless overwritten by extension)' do
    it 'does not allow create' do
      expect(policy.creation?).to be false
    end

    it 'does not allow update' do
      expect(policy.modification?).to be false
    end

    it 'does not allow destroy' do
      expect(policy.destruction?).to be false
    end

    it 'does not allow access' do
      expect(policy.access?).to be false
    end
  end

  describe '#authorized?' do
    it 'delegates to the `?` method for the action' do
      expect(policy).to receive(:derp?).and_return(true)
      expect(policy.authorized?(:derp)).to be_truthy

      expect(policy).to receive(:derp?).and_return(false)
      expect(policy.authorized?(:derp)).to be_falsey
    end

    it 'returns nil if the `?` method for the action does not exist' do
      expect(policy.authorized?(:derp)).to be_falsey
    end

    context 'when SystemAgent' do
      let(:policy) { Hipaapotamus::Policy.new(Hipaapotamus::SystemAgent.instance, protected) }

      it 'returns true' do
        expect(policy.authorized?(:derp)).to be_truthy
      end
    end
  end

  describe '#authorize!' do
    it 'raises AccountabilityError unless the `?` method for the action returns truthily' do
      expect(policy).to receive(:derp?).and_return(true)
      expect(policy.authorize!(:derp)).to be_truthy

      expect(policy).to receive(:derp?).and_return(false)
      expect { policy.authorize!(:derp) }.to raise_error AccountabilityError
    end
  end
end