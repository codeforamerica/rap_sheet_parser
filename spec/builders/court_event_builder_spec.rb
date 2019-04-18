require 'spec_helper'
require 'date'

module RapSheetParser
  RSpec.describe CourtEventBuilder do
    describe '.build' do
      it 'builds court event from treetop node' do
        text = <<~TEXT
          COURT:
          NAM:002
          19820915 CAMC LOS ANGELES METRO

          CNT:001 #456
          123 PC-BAD STUFF
          *DISPO:DISMISSED
          MORE INFO ABOUT THIS COUNT

          CNT:002
          4056 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
        TEXT

        event = build(text)

        verify_event_looks_like(
          event,
          name_code: '002',
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC Los Angeles Metro',
          sentence: ''
        )

        expect(event.counts.length).to eq 2

        verify_count_looks_like(
          event.counts[0],
          code_section: 'PC 123',
          code_section_description: 'BAD STUFF',
          severity: nil,
          convicted: false,
          sentence: ''
        )

        verify_count_looks_like(
          event.counts[1],
          code_section: 'PC 4056',
          code_section_description: 'BREAKING AND ENTERING',
          severity: nil,
          convicted: true,
          sentence: ''
        )
      end

      it 'populates updates' do
        text = <<~TEXT
          COURT: NAME7OZ
          19820915 CAMC LOS ANGELES METRO

          CNT:001 #123
          420 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT

           19990205
            DISPO:CONV SET ASIDE & DISM PER 1203.4 PC
        TEXT

        event = build(text)

        expect(event.dismissed_by_pc1203?).to eq true
      end

      it 'sets sentence correctly if sentence modified' do
        text = <<~TEXT
          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001 #346477
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL

          20040202
            DISPO :SOMETHING ELSE

          20040202
            DISPO:SENTENCE MODIFIED
            SEN: 001 MONTHS JAIL
        TEXT

        event = build(text)

        expect(event.sentence.jail).to eq 1.month
      end

      it 'handles a court event with no counts' do
        text = <<~TEXT
          COURT:
          20040102  CASC SAN FRANCISCO CO
        TEXT

        event = build(text)

        expect(event.case_number).to be_nil
      end

      it 'handles court events with page number breaks' do
        text = <<~TEXT
          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001  #346477
                    Page 2 of 29
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
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

        event = build(text)
        expect(event.counts.length).to eq 2
        expect(event.convicted_counts.length).to eq 2
        expect(event.convicted_counts[0].code).to eq 'PC'
        expect(event.convicted_counts[0].section).to eq '496'
        expect(event.convicted_counts[0].code_section).to eq 'PC 496'

        expect(event.convicted_counts[1].code).to eq 'HS'
        expect(event.convicted_counts[1].section).to eq '11357'
        expect(event.convicted_counts[1].code_section).to eq 'HS 11357'
      end
    end

    def build(text)
      tree = OtherCycleEventGrammarParser.new.parse(text)
      described_class.new(tree, logger: nil).build
    end
  end
end
