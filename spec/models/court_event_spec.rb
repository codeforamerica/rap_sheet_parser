require 'spec_helper'

module RapSheetParser
  RSpec.describe CourtEvent do
    describe '#severity' do
      it 'returns the highest severity found within the counts' do

        event = build_court_event(counts: [double(severity: 'F')])
        expect(event.severity).to eq 'F'

        event = build_court_event(counts: [double(severity: 'I'), double(severity: 'F')])
        expect(event.severity).to eq 'F'

        event = build_court_event(counts: [double(severity: 'I'), double(severity: 'M')])
        expect(event.severity).to eq 'M'

        event = build_court_event(counts: [double(severity: 'I'), double(severity: 'I')])
        expect(event.severity).to eq 'I'
      end
    end

    describe '#successfully_completed_probation?' do
      it 'returns false if any arrests or custody events within probation period' do
        conviction_event = build_court_event(
          sentence: ConvictionSentence.new(probation: 1.year),
          date: Date.new(1994, 1, 2)
        )
        arrest_event = ArrestEvent.new(date: Date.new(1994, 6, 2), counts: [])
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_event])

        expect(conviction_event.successfully_completed_probation?(rap_sheet)).to eq false
      end

      it 'skips events without dates' do
        conviction_event = build_court_event(
          sentence: ConvictionSentence.new(probation: 1.year),
          date: Date.new(1994, 1, 2)
        )
        arrest_no_date_event = ArrestEvent.new(date: nil, counts: [])
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_no_date_event])

        expect(conviction_event.successfully_completed_probation?(rap_sheet)).to eq true
      end

      it 'returns nil if event does not have a date' do
        conviction_event = build_court_event(
          sentence: ConvictionSentence.new(probation: 1.year),
          date: nil
        )
        arrest_no_date_event = ArrestEvent.new(date: nil, counts: [])
        events = build_rap_sheet(events: [conviction_event, arrest_no_date_event]).events

        expect(conviction_event.successfully_completed_probation?(events)).to be_nil
      end
    end

    describe '#successfully_completed_year?' do
      it 'returns false if any arrests or custody events within year' do
        conviction_event = build_court_event(
          date: Date.new(1994, 1, 2)
        )
        arrest_event = ArrestEvent.new(date: Date.new(1994, 6, 2), counts: [])
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_event])

        expect(conviction_event.successfully_completed_year?(rap_sheet)).to eq false
      end

      it 'skips events without dates' do
        conviction_event = build_court_event(
          sentence: ConvictionSentence.new(probation: 1.year),
          date: Date.new(1994, 1, 2)
        )
        arrest_no_date_event = ArrestEvent.new(date: nil, counts: [])
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_no_date_event])

        expect(conviction_event.successfully_completed_year?(rap_sheet)).to eq true
      end

      it 'returns nil if event does not have a date' do
        conviction_event = build_court_event(
          sentence: ConvictionSentence.new(probation: 1.year),
          date: nil
        )
        arrest_no_date_event = ArrestEvent.new(date: nil, counts: [])
        events = build_rap_sheet(events: [conviction_event, arrest_no_date_event]).events

        expect(conviction_event.successfully_completed_year?(events)).to be_nil
      end
    end
  end
end


