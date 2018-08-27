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

    describe '#successfully_completed_duration?' do
      it 'returns false if any arrests within probation period' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        arrest_event = build_arrest_event(date: Date.new(1994, 6, 2))
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any custody events within probation period' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        custody_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], header: 'custody')
        rap_sheet = build_rap_sheet(events: [conviction_event, custody_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any probation events within probation period' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        probation_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], header: 'probation')
        rap_sheet = build_rap_sheet(events: [conviction_event, probation_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any supplemental arrest events within probation period' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        supplemental_arrest_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], header: 'supplemental_arrest')
        rap_sheet = build_rap_sheet(events: [conviction_event, supplemental_arrest_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any mental health events within probation period' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        mental_health_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], header: 'mental_health')
        rap_sheet = build_rap_sheet(events: [conviction_event, mental_health_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'skips events without dates' do
        conviction_event = build_court_event(date: Date.new(1994, 1, 2))
        arrest_no_date_event = build_arrest_event(date: nil)
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_no_date_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq true
      end

      it 'returns nil if event does not have a date' do
        conviction_event = build_court_event(date: nil)
        arrest_no_date_event = build_arrest_event(date: nil)
        events = build_rap_sheet(events: [conviction_event, arrest_no_date_event]).events

        expect(conviction_event.successfully_completed_duration?(events, 1.year)).to be_nil
      end
    end
  end
end
