require 'spec_helper'

describe Hipaapotamus::AccountabilityContext do
  let(:agent) { User.create! }
  let(:accountability_context) { Hipaapotamus::AccountabilityContext.new(agent) }
  let(:protected) { MedicalSecret.create! }

  describe '#initialize' do
    it 'has a passed in agent' do
      expect(accountability_context.agent).to eq agent
    end

    it 'has no accessed records' do
      expect(accountability_context.accessed_records).to be_empty
    end

    context 'with a block' do
      it 'runs the block within the accountability_context' do
        accountability_context_within_block = nil
        accountability_context = Hipaapotamus::AccountabilityContext.new(agent) do
          accountability_context_within_block = Hipaapotamus::AccountabilityContext.current
        end

        expect(accountability_context_within_block).to eq accountability_context
      end
    end

    context 'without a valid agent' do
      it 'raises an AccountabilityError' do
        expect { Hipaapotamus::AccountabilityContext.new(protected) }.to raise_error(AccountabilityError)
      end
    end
  end

  describe '#record_access' do
    it 'stores a passed in record in accessed_records' do
      accountability_context.record_access(protected)
      expect(accountability_context.accessed_records).to include(protected)
    end
  end

  describe '.current' do
    context 'within an accountability_context' do
      it 'returns the current accountability_context' do
        accountability_context.within do
          expect(Hipaapotamus::AccountabilityContext.current).to eq accountability_context
        end
      end
    end

    context 'outside of an accountability_context' do
      it 'returns nil' do
        expect(Hipaapotamus::AccountabilityContext.current).to eq nil
      end
    end

    context 'within nested accountability_contexts' do
      let(:nested_accountability_context) { Hipaapotamus::AccountabilityContext.new(agent) }

      it 'returns the most recently nested accountability_context' do
        accountability_context.within do
          nested_accountability_context.within do
            expect(Hipaapotamus::AccountabilityContext.current).to eq nested_accountability_context
          end

          expect(Hipaapotamus::AccountabilityContext.current).to eq accountability_context
        end
      end
    end
  end

  describe '.current!' do
    context 'within an accountability_context' do
      it 'returns the current accountability_context' do
        accountability_context.within do
          expect(Hipaapotamus::AccountabilityContext.current!).to eq accountability_context
        end
      end
    end

    context 'outside of an accountability_context' do
      it 'raises an AccountabilityError' do
        expect { Hipaapotamus::AccountabilityContext.current! }.to raise_error(AccountabilityError)
      end
    end
  end
end