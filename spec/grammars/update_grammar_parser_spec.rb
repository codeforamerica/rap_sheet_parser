require 'spec_helper'

module RapSheetParser
  RSpec.describe UpdateGrammarParser do
    describe '#parse' do
      it 'parses updates' do
        text = <<~TEXT
          DISPO:SENTENCE MODIFIED
          SEN: 001 MONTHS JAIL
        TEXT

        tree = parse(text)
        expect(tree).to be_a(UpdateGrammar::Update)
        expect(tree.dispositions[0].disposition_type).to be_a(UpdateGrammar::SentenceModified)
      end

      it 'parses dismissals' do
        text = <<~TEXT
          DISPO:CONV SET ASIDE & DISM PER 1203.4 PC
        TEXT

        tree = parse(text)
        expect(tree).to be_a(UpdateGrammar::Update)
        expect(tree.dispositions[0].disposition_type).to be_a(UpdateGrammar::PC1203Dismissed)
      end

      it 'parses updates with stray information before it' do
        text = <<~TEXT
          Page 3
          DISPO:SENTENCE MODIFIED
          SEN: 001 MONTHS JAIL
        TEXT

        tree = parse(text)
        expect(tree).to be_a(UpdateGrammar::Update)
      end
    end

    def parse(text)
      described_class.new.parse(text)
    end
  end
end
