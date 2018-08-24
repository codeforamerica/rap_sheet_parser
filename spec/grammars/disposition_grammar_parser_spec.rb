require 'spec_helper'

module RapSheetParser
  RSpec.describe DispositionGrammarParser do
    describe '#parse' do
      it 'parses disposition' do
        text = <<~TEXT
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.disposition_type).to be_a CountGrammar::Convicted
        expect(disposition.severity.text_value).to eq 'MISDEMEANOR'
        expect(disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL'
        expect(disposition.sentence.probation.text_value).to eq '012 MONTHS PROBATION'
        expect(disposition.sentence.jail.text_value).to eq '045 DAYS JAIL'
      end

      it 'handles stray characters and whitespace in the disposition line' do
        text = <<~TEXT
          DI SP O:CONVICTED blah .
          CONV STATUS:MISDEMEANOR
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.disposition_type).to be_a CountGrammar::Convicted
        expect(disposition.severity.text_value).to eq 'MISDEMEANOR'
      end

      it 'can parse convictions with semicolon instead of colon' do
        text = <<~TEXT
          DISPO;CONVICTED
          CONV STATUS:FELONY
        TEXT

        disposition = described_class.new.parse(text)

        expect(disposition.disposition_type).to be_a CountGrammar::Convicted
      end

      it 'can parse convictions with spaces in dispo convicted' do
        text = <<~TEXT
          DISPO:CO  N VI CTE D
          CONV STATUS:FELONY
        TEXT

        disposition = described_class.new.parse(text)

        expect(disposition.disposition_type).to be_a CountGrammar::Convicted
      end

      it 'can parse convictions with missing severity lines' do
        text = <<~TEXT
          DISPO:CONVICTED
        TEXT

        disposition = described_class.new.parse(text)

        expect(disposition.disposition_type).to be_a CountGrammar::Convicted
      end

      it 'can parse whitespace in severity lines' do
        text = <<~TEXT
          DISPO:CONVICTED
           CONV STATUS : FELONY
        TEXT

        disposition = described_class.new.parse(text)

        expect(disposition.severity.text_value).to eq 'FELONY'
      end

      it 'parses multiple line sentences where the sentence is last' do
        text = <<~TEXT
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
               CONCURRENT
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
      end

      it 'parses out junk characters from sentences' do
        text = <<~TEXT
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          ' SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT
          - .
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
      end

      it 'parses multiple line sentences where another specific line type comes after the sentence' do
        text = <<~TEXT
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
               CONCURRENT
          COM: hello world
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
      end

      it 'parses multiple line sentences where a date marker comes after the sentence' do
        text = <<~TEXT
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
               CONCURRENT
          20130116
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
      end

      it 'parses sentences found in comments with a SEN-X header' do
        text = <<~TEXT
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
          COM: CNT 01 CHRG-484-487 (A) PC
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN'
        expect(disposition.sentence.probation.text_value).to eq '3 YR PROB'
        expect(disposition.sentence.jail.text_value).to eq '6 MO JL WORK'
        expect(disposition.sentence.details[0].text_value).to eq '$971 FINE $420 RSTN'
      end

      it 'parses sentences found in comments with a SEN-X, header' do
        text = <<~TEXT
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          COM: SEN-X,3 YR PROB
          COM: CNT 01 CHRG-484-487 (A) PC
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.probation.text_value).to eq '3 YR PROB'
      end

      it 'parses sentences found in comments with an XSEN header' do
        text = <<~TEXT
          *DISPO: CONVICTED
          CONV STATUS :MISDEMEANOR
          COM: XSEN:3 YR PROB,90 DS JL, FINE FNSS RSTN
          COM: CNT 02 CHRG-666 PC
          DCN:T6014082460234000096
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.sentence.text_value).to eq '3 YR PROB,90 DS JL, FINE FNSS RSTN'
        expect(disposition.sentence.probation.text_value).to eq '3 YR PROB'
        expect(disposition.sentence.jail.text_value).to eq '90 DS JL'
        expect(disposition.sentence.details[0].text_value).to eq 'FINE FNSS RSTN'
      end

      it 'parses code section in the comments' do
        text = <<~TEXT
          DISPO: CONVICTED
          CONV STATUS :MISDEMEANOR
          COM: XSEN:3 YR PROB,90 DS JL, FINE FNSS RSTN
          COM: CNT 02 CHRG-666 PC
          DCN:T6014082460234000096
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.code_section.text_value).to eq '666 PC'
      end

      it 'parses when code section missing' do
        text = <<~TEXT
          DISPO:CONVICTED
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.code_section).to be_nil
      end

      it 'parses dismissals' do
        text = <<~TEXT
          DISPO:CONV SET ASIDE & DISM PER 1203.4 PC
        TEXT

        disposition = described_class.new.parse(text)
        expect(disposition.disposition_type).to be_a(DispositionGrammar::PC1203Dismissed)
      end
    end
  end
end
