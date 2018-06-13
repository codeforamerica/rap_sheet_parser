require 'spec_helper'
require 'rap_sheet_parser'

module RapSheetParser
  RSpec.describe SentenceGrammarParser do
    describe '#parse' do
      it 'parses sentence parts' do
        text = 'FINE SS, 012 MONTHS PROBATION, 045 DAYS JAIL, 001 YEARS PRISON, ANOTHER ONE'

        sentence = described_class.new.parse(text)

        expect(sentence.probation.text_value).to eq '012 MONTHS PROBATION'
        expect(sentence.jail.text_value).to eq '045 DAYS JAIL'
        expect(sentence.prison.text_value).to eq '001 YEARS PRISON'
        expect(sentence.details[0].text_value).to eq 'FINE SS'
        expect(sentence.details[1].text_value).to eq 'ANOTHER ONE'
      end

      it 'parses concurrent jail sentences and prison ss sentences' do
        text = '1 YR PRISON SS, 1 YR JL CC'

        sentence = described_class.new.parse(text)
        expect(sentence.details.length).to eq 2
      end

      it 'does not consume trailing commas into details' do
        text = '012 MONTHS PRISON, '

        sentence = described_class.new.parse(text)

        expect(sentence.details.length).to eq 0
        expect(sentence.prison.text_value).to eq '012 MONTHS PRISON'
      end

      it 'parses jail time without duration' do
        text = 'JAIL'

        sentence = described_class.new.parse(text)
        expect(sentence.jail.text_value).to eq 'JAIL'
      end

      it 'parses probation without duration' do
        text = 'PROBATION,270 DAYS JAIL, IMP SEN SS'

        sentence = described_class.new.parse(text)
        expect(sentence.probation.text_value).to eq 'PROBATION'
      end

      it 'parses prison without duration' do
        text = 'PRISON,270 DAYS JAIL, IMP SEN SS'

        sentence = described_class.new.parse(text)
        expect(sentence.prison.text_value).to eq 'PRISON'
      end

      it 'parses leading commas' do
        text = ' , FINE'

        sentence = described_class.new.parse(text)
        expect(sentence.details.length).to eq 1
        expect(sentence.details[0].text_value).to eq 'FINE'
      end

      it 'parses empty sections' do
        text = ', , FINE'

        sentence = described_class.new.parse(text)
        expect(sentence.details.length).to eq 1
        expect(sentence.details[0].text_value).to eq 'FINE'
      end
    end
  end
end

