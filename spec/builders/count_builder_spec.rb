require 'spec_helper'

module RapSheetParser
  RSpec.describe CountBuilder do
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
        20000101
          DISPO:SENTENCE MODIFIED
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      count_node = tree.cycles[0].events[0].counts[0]

      subject = described_class.new(count_node, logger: logger).build
      expect(subject.code_section).to eq 'PC 496'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.disposition.severity).to eq 'M'
      expect(subject.disposition.type).to eq 'convicted'
      expect(subject.disposition.sentence.to_s).to eq '12m probation, 45d jail'
      expect(subject.updates.length).to eq 1
      expect(subject.updates[0].dispositions[0].type).to eq 'sentence_modified'

      expect(log.string).to be_empty
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
      expect(subject.disposition.severity).to be_nil
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
      expect(subject.disposition.severity).to eq 'M'
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
      expect(subject.disposition.severity).to eq 'M'
    end

    context 'when the charge contains a -664 (Attempted)' do
      it 'parses that into the code section' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CASC SN JOSE

          CNT: 001  #346477
            SEE COMMENT FOR CHARGE
          *DISPO:CONVICTED
            COM: CHRG 487(A)-664 PC
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        count_node = tree.cycles[0].events[0].counts[0]

        subject = described_class.new(count_node, logger: logger).build
        expect(subject.code_section).to eq 'PC 487(a)-664'
      end
    end

    context 'when the charge contains flags' do
      it 'parses flags into the count' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CASC SN JOSE

          CNT: 001  #346477
            -ATTEMPTED           -BENCH WARRANT
            SEE COMMENT FOR CHARGE
          *DISPO:CONVICTED
            COM: CHRG 487(A)-664 PC
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        count_node = tree.cycles[0].events[0].counts[0]

        subject = described_class.new(count_node, logger: logger).build
        expect(subject.flags).to contain_exactly('-ATTEMPTED', '-BENCH WARRANT')
      end
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

    context 'when there is a probation revoked sentence update' do
      let(:text) do
        <<~TEXT
          info 
          * * * *
          COURT: NAM:02
          19930917 CASC SAN FRANCISCO CO

          CNT:01 #684866-77
          32 PC-ACCESSORY
          *DISPO:CONVICTED

          CONV STATUS:FELONY
          SEN: 3 YEARS PROBATION,6 MONTHS JAIL,
          IMP SEN SS

          19960628
          DISPO:PROBATION REVOKED
          SEN: 16 MONTHS PRISON
          * * * END OF MESSAGE * * *
        TEXT
      end

      it 'returns an updated sentence' do


        tree = RapSheetGrammarParser.new.parse(text)
        count_node = tree.cycles[0].events[0].counts[0]

        subject = described_class.new(count_node, logger: logger).build

        expect(subject.disposition.type).to eq 'convicted'
        expect(subject.updates[0].dispositions[0].type).to eq 'probation_revoked'
        expect(subject.disposition.original_sentence.to_s).to eq "3y probation, 6m jail, imp sen ss"
        expect(subject.disposition.most_recent_sentence.to_s).to eq '16m prison'
        expect(subject.disposition.sentence_start_date).to eq Date.new(1996, 6, 28)
        expect(subject.updates.length).to eq 1
        expect(subject.probation_revoked?).to eq true
      end
    end
  end
end
