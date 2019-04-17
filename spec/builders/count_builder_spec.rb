require 'spec_helper'

module RapSheetParser
  RSpec.describe CountBuilder do
    let(:event) { { some: 'event' } }
    let(:log) { StringIO.new }
    let(:logger) { Logger.new(log) }
    let(:event_date) { Date.new(1982, 9, 15) }

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

      subject = described_class.new(count_node, event_date: event_date, logger: logger).build
      expect(subject.code_section).to eq 'PC 496'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.severity).to eq 'M'
      expect(subject.convicted?).to be true
      expect(subject.sentence.to_s).to eq '12m probation, 45d jail'
      expect(subject.dispositions.length).to eq 2
      expect(subject.dispositions[1].type).to eq 'sentence_modified'

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

      subject = described_class.new(count_node, event_date: event_date, logger: logger).build
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

      subject = described_class.new(count_node, event_date: event_date, logger: logger).build
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
      subject = described_class.new(count_node, event_date: event_date, logger: logger).build
      expect(subject.code_section).to eq 'PC 496.3(a)(2)'
      expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      expect(subject.severity).to eq 'M'
    end

    context 'when a page number breaks up a count' do
      it 'parses the count without the page number' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAM:001
          19900626 CAMC SAN JOSE
           CNT: 001  #346477
                    Page 2 of 29
            496.3(A)(2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
           CNT:002
          Page 13 of 16
            11357 HS-POSSESS
          TOC:M
          *DISPO:CONVICTED
          CONV STATUS:FELONY
          SEN: 002 YEARS PROBATION, 045 DAYS JAIL, FINE, IMP SEN SS
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        count_node_1 = tree.cycles[0].events[0].counts[0]

        subject_1 = described_class.new(count_node_1, event_date: event_date, logger: logger).build
        expect(subject_1.code).to eq 'PC'
        expect(subject_1.section).to eq '496.3(a)(2)'
        expect(subject_1.code_section).to eq 'PC 496.3(a)(2)'
        expect(subject_1.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
        expect(subject_1.severity).to eq 'M'

        count_node_2 = tree.cycles[0].events[0].counts[1]

        subject_2 = described_class.new(count_node_2, event_date: event_date, logger: logger).build
        expect(subject_2.code_section).to eq 'HS 11357'
        expect(subject_2.code_section_description).to eq 'POSSESS'
        expect(subject_2.severity).to eq 'F'
      end
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

        subject = described_class.new(count_node, event_date: event_date, logger: logger).build
        expect(subject.code_section).to eq 'PC 487(a)-664'
      end
    end

    context 'when there are no dispositions' do
      it 'returns an empty array for dispositions' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CASC SN JOSE

          CNT: 001  #346477
            SEE COMMENT FOR CHARGE
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        count_node = tree.cycles[0].events[0].counts[0]

        subject = described_class.new(count_node, event_date: event_date, logger: logger).build
        expect(subject.dispositions).to eq []
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

        subject = described_class.new(count_node, event_date: event_date, logger: logger).build
        expect(subject.flags).to contain_exactly('-ATTEMPTED', '-BENCH WARRANT')
      end
    end

    context 'when there is a single probation revoked sentence update' do
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

          20110505
          DISPO:REDUCED TO MISDEMEANOR
          * * * END OF MESSAGE * * *
        TEXT
      end

      it 'returns an updated sentence' do
        tree = RapSheetGrammarParser.new.parse(text)
        count_node = tree.cycles[0].events[0].counts[0]

        subject = described_class.new(count_node, event_date: Date.new(1993, 9, 17), logger: logger).build

        expect(subject.convicted?).to eq true
        expect(subject.dispositions.length).to eq 3
        expect(subject.dispositions[0].type).to eq 'convicted'
        expect(subject.dispositions[1].type).to eq 'probation_revoked'
        expect(subject.dispositions[0].sentence.to_s).to eq '3y probation, 6m jail, imp sen ss'
        expect(subject.dispositions[1].sentence.to_s).to eq '16m prison'
        expect(subject.dispositions[0].date).to eq Date.new(1993, 9, 17)
        expect(subject.dispositions[1].date).to eq Date.new(1996, 6, 28)
        expect(subject.sentence.to_s).to eq '16m prison'
        expect(subject.probation_revoked?).to eq true
      end
    end
  end
end
