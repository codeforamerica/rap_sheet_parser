require 'spec_helper'

module RapSheetParser
  RSpec.describe CourtCountBuilder do
    let(:event) { { some: 'event' } }
    let(:log) { StringIO.new }
    let(:logger) { Logger.new(log) }

    it 'populates values representing count' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CASC SN JOSE

        CNT: 001  #346477
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      count_node = tree.cycles[0].events[0].counts[0]

      subject = described_class.new(count_node, logger: logger).build
      expect(subject.code_section).to eq 'PC 496'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.severity).to eq 'M'
      expect(subject.disposition).to eq 'convicted'
      expect(log.string).to eq('')
    end

    it 'returns nil fields when information not present' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CASC SN JOSE

        CNT: 001  #346477
          DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      count_node = tree.cycles[0].events[0].counts[0]

      subject = described_class.new(count_node, logger: logger).build
      expect(subject.code_section).to be_nil
      expect(subject.code_section_description).to be_nil
      expect(subject.severity).to be_nil
    end

    it 'strips whitespace out of the code section number and downcases letters' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CASC SN JOSE

        CNT: 001  #346477
          496 (A) (2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      count_node = tree.cycles[0].events[0].counts[0]

      subject = described_class.new(count_node, logger: logger).build
      expect(subject.code_section).to eq 'PC 496(a)(2)'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.severity).to eq 'M'
    end

    it 'replaces commas with periods in the code section number' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CASC SN JOSE

        CNT: 001  #346477
          496,3(A)(2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      count_node = tree.cycles[0].events[0].counts[0]
      subject = described_class.new(count_node, logger: logger).build
      expect(subject.code_section).to eq 'PC 496.3(a)(2)'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.severity).to eq 'M'
    end

    context 'when the charge description contains 28.5' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:
          20040102  CASC SAN FRANCISCO CO
  
          CNT: 001 #346477
            1136(A) HS-GIVE/ETC MARIJ OVER 1 OZ/#{quantity} GRM
          *DISPO:CONVICTED
          * * * END OF MESSAGE * * *
        TEXT
      end

      context 'with a period' do
        let(:quantity) { '28.5' }

        it 'emits a warning' do
          tree = RapSheetGrammarParser.new.parse(text)
          count_node = tree.cycles[0].events[0].counts[0]
          described_class.new(count_node, logger: logger).build

          expect(log.string).to include 'WARN -- : Charge description includes "28.5"'
        end
      end

      context 'with a comma' do
        let(:quantity) { '28,5' }

        it 'emits a warning' do
          tree = RapSheetGrammarParser.new.parse(text)
          count_node = tree.cycles[0].events[0].counts[0]
          described_class.new(count_node, logger: logger).build

          expect(log.string).to include 'WARN -- : Charge description includes "28.5"'
        end
      end
    end
  end
end
