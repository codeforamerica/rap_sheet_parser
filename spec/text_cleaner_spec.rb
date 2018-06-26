require 'spec_helper'
require 'rap_sheet_parser'

module RapSheetParser
  RSpec.describe TextCleaner do
    describe '.clean' do
      it 'replaces commonly mis-scanned text' do
        expect(clean('FOO ÇNT: FOO')).to eq('FOO CNT: FOO')
        expect(clean('WRONG–DASH')).to eq('WRONG-DASH')
        expect(clean('CNI: HI')).to eq('CNT: HI')
        expect(clean("\f")).to eq('')
      end

      it 'upcases all text' do
        expect(clean('abcD')).to eq 'ABCD'
      end
    end

    describe '.clean_sentence' do
      it 'removes periods' do
        result = described_class.clean_sentence('01.2 MONTHS PROBATION')
        expect(result).to eq '012 MONTHS PROBATION'
      end

      it 'removes quotes' do
        result = described_class.clean_sentence("'006 MONTHS JAIL'")
        expect(result).to eq '006 MONTHS JAIL'
      end

      it 'removes lines with less than 3 characters' do
        result = described_class.clean_sentence("FINE SS,\nA\nBBB\nCCCC")
        expect(result).to eq('FINE SS, CCCC')
      end

      it 'replaces newlines with spaces' do
        result = described_class.clean_sentence("006 MONTHS JAIL,\nFINE")
        expect(result).to eq('006 MONTHS JAIL, FINE')
      end
    end
  end
end

def clean(text)
  RapSheetParser::TextCleaner.clean(text)
end
