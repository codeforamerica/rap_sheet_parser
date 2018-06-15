require 'spec_helper'
require 'date'
require 'rap_sheet_parser'

module RapSheetParser
  RSpec.describe ConvictionEventBuilder do
    describe '.present' do
      it 'returns arrest, custody, and court events with convictions' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CAMC L05 ANGELES METRO

          CNT:001 #456
          4056 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        event = described_class.new(tree.cycles[0].events[0]).build

        verify_event_looks_like(event, {
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC L05 ANGELES METRO',
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
          19820915 CAMC L05 ANGELES METRO

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

        tree = RapSheetGrammarParser.new.parse(text)
        event = described_class.new(tree.cycles[0].events[0]).build

        verify_event_looks_like(event, {
          date: Date.new(1982, 9, 15),
          case_number: '123',
          courthouse: 'CAMC L05 ANGELES METRO',
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

      it 'populates 1203 dismissal field' do
        text = <<~TEXT
          info
          * * * *
          COURT: NAME7OZ
          19820915 CAMC L05 ANGELES METRO

          CNT:001 #123
          420 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT

          19990205
            DISPO:CONV SET ASIDE & DISM PER 1203.4 PC
          * * * END OF MESSAGE * * *
        TEXT

        tree = RapSheetGrammarParser.new.parse(text)
        event = described_class.new(tree.cycles[0].events[0]).build

        expect(event.dismissed_by_pc1203?).to eq true
      end

    end

    def verify_event_looks_like(event, date:, case_number:, courthouse:, sentence:)
      expect(event.date).to eq date
      expect(event.case_number).to eq case_number
      expect(event.courthouse).to eq courthouse
      expect(event.sentence.to_s).to eq sentence
    end

    def verify_count_looks_like(count, code_section:, code_section_description:, severity:)
      expect(count.code_section).to eq code_section
      expect(count.code_section_description).to eq code_section_description
      expect(count.severity).to eq severity
    end
  end
end
