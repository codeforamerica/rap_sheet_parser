require 'spec_helper'

module RapSheetParser
  RSpec.describe CaseNumberBuilder do
    it 'strips whitespace from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO

        CNT: 001 #45      6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      case_number_node = tree.cycles[0].events[0].case_number
      expect(described_class.new(case_number_node).build).to eq '456'
    end

    it 'strips trailing punctuation from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO

        CNT: 001 #456.:-
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      case_number_node = tree.cycles[0].events[0].case_number

      expect(described_class.new(case_number_node).build).to eq '456'
    end

    it 'strips periods from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO

        CNT: 001 #4.5.6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      case_number_node = tree.cycles[0].events[0].case_number

      expect(described_class.new(case_number_node).build).to eq '456'
    end

    it 'returns nil case number for an unknown case number' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO

        CNT: 001
        garbled
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      case_number_node = tree.cycles[0].events[0].case_number

      expect(described_class.new(case_number_node).build).to eq nil
    end
  end
end
