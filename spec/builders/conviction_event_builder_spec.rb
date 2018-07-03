require 'spec_helper'
require 'date'

module RapSheetParser
  RSpec.describe ConvictionEventBuilder do
    describe '.build' do
      it 'builds court event from treetop node' do
        text = <<~TEXT
          info
          * * * *
          COURT:
          NAM:002
          19820915 CAMC LOS ANGELES METRO

          CNT:001 #456
          4056 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
          * * * END OF MESSAGE * * *
        TEXT

        event = build(text)

        verify_event_looks_like(event, {
          name_code: '002',
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC Los Angeles Metro',
          sentence: '',
        })

        verify_count_looks_like(event.counts[0], {
          code_section: 'PC 4056',
          code_section_description: 'BREAKING AND ENTERING',
          severity: nil,
        })
      end

      it 'returns multiple count objects for multiple count listings' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CAMC LOS ANGELES METRO

          CNT:001-002 #123
          420 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT

          CNT:003-005
          4056 PC-SECOND DESCRIPTION
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
          * * * END OF MESSAGE * * *
        TEXT

        event = build(text)

        verify_event_looks_like(event, {
          name_code: nil,
          date: Date.new(1982, 9, 15),
          case_number: '123',
          courthouse: 'CAMC Los Angeles Metro',
          sentence: '',
        })

        verify_count_looks_like(event.counts[0], {
          code_section: 'PC 420',
          code_section_description: 'BREAKING AND ENTERING',
          severity: nil,
        })

        verify_count_looks_like(event.counts[1], {
          code_section: 'PC 420',
          code_section_description: 'BREAKING AND ENTERING',
          severity: nil,
        })
        verify_count_looks_like(event.counts[2], {
          code_section: 'PC 4056',
          code_section_description: 'SECOND DESCRIPTION',
          severity: nil,
        })
        verify_count_looks_like(event.counts[3], {
          code_section: 'PC 4056',
          code_section_description: 'SECOND DESCRIPTION',
          severity: nil,
        })
        verify_count_looks_like(event.counts[4], {
          code_section: 'PC 4056',
          code_section_description: 'SECOND DESCRIPTION',
          severity: nil,
        })
      end

      it 'populates updates' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CAMC LOS ANGELES METRO

          CNT:001 #123
          420 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT

           19990205 
            DISPO:CONV SET ASIDE & DISM PER 1203.4 PC
          * * * END OF MESSAGE * * *
        TEXT

        event = build(text)

        expect(event.dismissed_by_pc1203?).to eq true
      end

      it 'sets sentence correctly if sentence modified' do
        text = <<~TEXT
          info
          * * * *
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
          * * * END OF MESSAGE * * *
        TEXT

        event = build(text)

        expect(event.sentence.jail).to eq 1.month
      end
    end

    def build(text)
      tree = RapSheetGrammarParser.new.parse(text)
      described_class.new(tree.cycles[0].events[0], logger: nil).build
    end
  end
end
