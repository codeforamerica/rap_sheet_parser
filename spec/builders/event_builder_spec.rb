require 'ostruct'
require 'spec_helper'

module RapSheetParser
  RSpec.describe EventBuilder do
    it 'creates dates from date strings' do
      text = <<~TEXT
        ARR/DET/CITE:
        NAM:001
        19820102 CAPD CONCORD
        TOC:F
        CNT:001
        #65131
        496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      TEXT

      event_node = OtherCycleEventGrammarParser.new.parse(text)
      event = RapSheetParser::TestBuilder.new(event_node, logger: nil).build

      expect(event.date).to eq Date.new(1982, 1, 2)
      expect(event.agency).to eq 'CAPD CONCORD'
    end

    it 'creates multiple count objects for multiple count listings' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC LOS ANGELES METRO

        CNT:001 #123
        455 PC-ARMED ROBBERY
        *DISPO:CONVICTED
        MORE INFO ABOUT THIS COUNT

        CNT:002
        420 PC-BREAKING AND ENTERING
        *DISPO:DISMISSED
        MORE INFO ABOUT THIS COUNT

        CNT:003-005
        4056 PC-SECOND DESCRIPTION
        *DISPO:CONVICTED
        MORE INFO ABOUT THIS COUNT
      TEXT

      event_node = OtherCycleEventGrammarParser.new.parse(text)
      event = RapSheetParser::TestBuilder.new(event_node, logger: nil).build

      verify_count_looks_like(event.counts[0], {
        code_section: 'PC 455',
        code_section_description: 'ARMED ROBBERY',
        severity: nil,
        disposition: 'convicted',
        sentence: '',
      })

      verify_count_looks_like(event.counts[1], {
        code_section: 'PC 420',
        code_section_description: 'BREAKING AND ENTERING',
        severity: nil,
        disposition: 'dismissed',
        sentence: '',
      })
      verify_count_looks_like(event.counts[2], {
        code_section: 'PC 4056',
        code_section_description: 'SECOND DESCRIPTION',
        severity: nil,
        disposition: 'convicted',
        sentence: '',
      })
      verify_count_looks_like(event.counts[3], {
        code_section: 'PC 4056',
        code_section_description: 'SECOND DESCRIPTION',
        severity: nil,
        disposition: 'convicted',
        sentence: '',
      })
      verify_count_looks_like(event.counts[4], {
        code_section: 'PC 4056',
        code_section_description: 'SECOND DESCRIPTION',
        severity: nil,
        disposition: 'convicted',
        sentence: '',
      })
    end

    class TestBuilder
      include EventBuilder

      def build
        OpenStruct.new(date: date, agency: agency, counts: counts)
      end
    end
  end
end
