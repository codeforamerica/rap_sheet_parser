require 'spec_helper'

module RapSheetParser
  RSpec.describe RapSheet do
    describe '#sex_offender_registration?' do
      it 'returns true if registration event containing PC 290' do
        event = build_other_event(
          event_type: 'registration',
          counts: [build_count(code: 'PC', section: '290')]
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq true
      end

      it 'returns true if registration event starting with PC 290' do
        event = build_other_event(
          event_type: 'registration',
          counts: [build_count(code: 'PC', section: '290(a)')]
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq true
      end

      it 'returns false if no registration event containing PC 290' do
        event = build_other_event(
          event_type: 'registration',
          counts: [build_count(code: 'HS', section: '11590')]
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq false
        expect(rap_sheet.narcotics_offender_registration?).to eq true
      end
    end

    describe '#arrest_events' do
      it 'returns arrests' do
        arrest = build_arrest_event
        custody = build_other_event(event_type: 'custody')

        rap_sheet = build_rap_sheet(events: [arrest, custody])
        expect(rap_sheet.arrest_events[0]).to eq arrest
      end
    end

    describe '#superstrikes' do
      it 'returns any superstrike convictions' do
        count = build_count(code: 'PC', section: '187', dispositions: [build_disposition(type: 'convicted')])
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.superstrikes).to contain_exactly(count)
      end

      it 'returns empty list if no superstrike convictions' do
        count = build_count(code: 'PC', section: '187', dispositions: [build_disposition(type: 'dismissed')])
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.superstrikes).to be_empty
      end
    end
    describe '#convictions' do
      it 'returns an array of convicted court events' do
        convicted_count = build_count(code: 'PC', section: '32', dispositions: [build_disposition(type: 'convicted')])
        dismissed_count = build_count(code: 'HS', section: '11359', dispositions: [build_disposition(type: 'dismissed')])
        court_event1 = build_court_event(counts: [convicted_count])
        court_event2 = build_court_event(counts: [dismissed_count])
        rap_sheet = build_rap_sheet(events: [court_event1, court_event2, build_arrest_event])
        expect(rap_sheet.convictions).to contain_exactly(court_event1)
      end
    end
    describe '#currently_serving_sentence?' do
      it 'returns true if at least one event has a sentence that is not complete' do
        disposition = build_disposition(type: 'convicted', sentence: ConvictionSentence.new(probation: 3.years, date: Date.today - 2.years))
        count = build_count(code: 'PC', section: '187', dispositions: [disposition])
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.currently_serving_sentence?).to eq(true)
      end
      it 'returns false if no events have incomplete sentences' do
        disposition = build_disposition(type: 'convicted', sentence: ConvictionSentence.new(probation: 3.years, date: Date.today - 4.years))
        count = build_count(code: 'PC', section: '187', dispositions: [disposition])
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.currently_serving_sentence?).to eq(false)
      end
    end
  end
end
