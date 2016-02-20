require 'spec_helper'

describe Hipaapotamus::ModelPolicy do
  let(:agent) { User.create! }
  let(:defended) { Hipaapotamus.without_accountability { Untainted.create! } }
  let(:model_policy) { Hipaapotamus.with_accountability(agent) { defended.policy } }

  context 'by default (unless overwritten by extension)' do
    it 'does not allow create' do
      expect(model_policy.creation?).to be false
    end

    it 'does not allow update' do
      expect(model_policy.modification?).to be false
    end

    it 'does not allow destroy' do
      expect(model_policy.destruction?).to be false
    end

    it 'does not allow access' do
      expect(model_policy.access?).to be false
    end
  end

  describe '#authorized?' do
    it 'delegates to the `?` method for the action' do
      expect(model_policy).to receive(:derp?).and_return(true)
      expect(model_policy.authorized?(:derp)).to be_truthy

      expect(model_policy).to receive(:derp?).and_return(false)
      expect(model_policy.authorized?(:derp)).to be_falsey
    end

    it 'blows up if the `?` method for the action does not exist' do
      expect { model_policy.authorized?(:derp) }.to raise_error NameError
    end

    context 'when SystemAgent' do
      let(:model_policy) { Hipaapotamus.with_accountability(Hipaapotamus::SystemAgent.instance) { defended.policy } }

      it 'returns true' do
        expect(model_policy.authorized?(:derp)).to be_truthy
      end
    end
  end

  describe '#authorize!' do
    it 'raises Hipaapotamus::AccountabilityError unless the `?` method for the action returns truthily' do
      expect(model_policy).to receive(:derp?).and_return(true)
      expect(model_policy.authorize!(:derp)).to be_truthy

      expect(model_policy).to receive(:derp?).and_return(false)
      expect { model_policy.authorize!(:derp) }.to raise_error Hipaapotamus::AccountabilityError
    end
  end

  describe '#defended_class_name' do
    it 'returns the class name without the Class on the end' do
      expect(UntaintedPolicy.defended_class_name).to eq 'Untainted'
    end
  end

  describe '#defended_class' do
    it 'returns the class of the defended' do
      expect(UntaintedPolicy.defended_class).to be Untainted
    end
  end

  describe '#collection_policy' do
    let(:collection_policy) { UntaintedPolicy.collection_policy_class.new(agent, Untainted) }

    describe '#resolve_scope' do
      it 'defaults to none' do
        expect(collection_policy.resolve_scope).to eq Untainted.none
      end

      it 'falls back to none' do
        allow(collection_policy).to receive(:scope).and_return(nil)

        expect(collection_policy.resolve_scope).to eq Untainted.none
      end

      context 'for normal agents' do
        it 'delegates to #scope' do
          allow(collection_policy).to receive(:scope).and_return(Untainted.where(id: 7))

          expect(collection_policy.resolve_scope).to eq Untainted.where(id: 7)
        end
      end

      context 'for system agents' do
        let(:agent) { Hipaapotamus::SystemAgent.instance }

        it 'returns all' do
          expect(collection_policy.resolve_scope).to eq Untainted.all
        end
      end
    end
  end

end