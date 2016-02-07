require 'spec_helper'

describe Hipaapotamus::Policy do
  let(:agent) { User.create! }
  let(:protected) { Hipaapotamus.without_accountability { Untainted.create! } }
  let(:policy) { UntaintedPolicy.new(agent, protected) }

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
      let(:policy) { UntaintedPolicy.new(Hipaapotamus::SystemAgent.instance, protected) }

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

  describe '#protected_class_name' do
    it 'returns the class name without the Class on the end' do
      expect(UntaintedPolicy.protected_class_name).to eq 'Untainted'
    end
  end

  describe '#protected_class' do
    it 'returns the class of the protected' do
      expect(UntaintedPolicy.protected_class).to be Untainted
    end
  end

  describe '#inherited' do
    it 'defines an instance method with an intuative name that can be used to access the protected' do
      expect(UntaintedPolicy.instance_methods).to include :untainted
    end
  end

  describe '#resolve_scope' do
    it 'defaults to none' do
      expect(UntaintedPolicy.resolve_scope(agent)).to eq Untainted.none
    end

    it 'falls back to none' do
      allow(UntaintedPolicy).to receive(:scope).and_return(nil)

      expect(UntaintedPolicy.resolve_scope(agent)).to eq Untainted.none
    end

    context 'for normal agents' do
      it 'delegates to #scope' do
        allow(UntaintedPolicy).to receive(:scope).and_return(Untainted.where(id: 7))

        expect(UntaintedPolicy.resolve_scope(agent)).to eq Untainted.where(id: 7)
      end
    end

    context 'for system agents' do
      let(:agent) { Hipaapotamus::SystemAgent.instance }

      it 'returns all' do
        expect(UntaintedPolicy.resolve_scope(agent)).to eq Untainted.all
      end
    end
  end

end