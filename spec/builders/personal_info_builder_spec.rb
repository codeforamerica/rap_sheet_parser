require 'spec_helper'

module RapSheetParser
  RSpec.describe PersonalInfoBuilder do
    describe '#build' do
      it 'populates the sex field in PersonalInfo' do
        text = <<~TEXT
          blah blah
          SEX/F
          la la la
          * * * *
          cycle text
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)

        personal_info = described_class.new(tree.personal_info).build
        expect(personal_info.sex).to eq 'F'
      end

      it 'returns an empty PersonalInfo if not found' do
        text = <<~TEXT
          blah blah
          * * * *
          cycle text
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)

        personal_info = described_class.new(tree.personal_info).build
        expect(personal_info).to eq nil
      end
    end
  end
end
