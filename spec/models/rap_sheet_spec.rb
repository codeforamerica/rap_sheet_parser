require 'spec_helper'

module RapSheetParser
  RSpec.describe RapSheet do
    describe '#sex_offender_registration?' do
      it 'returns true if registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'PC 290'
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq true
      end

      it 'returns true if registration event starting with PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'PC 290(a)'
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq true
      end

      it 'returns false if no registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'HS 11590'
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq false
      end

      it 'returns false if no registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'HS 11590'
        )

        rap_sheet = build_rap_sheet(events: [event])
        expect(rap_sheet.sex_offender_registration?).to eq false
        expect(rap_sheet.narcotics_offender_registration?).to eq true
      end
    end

    describe '#arrests' do
      it 'returns arrests' do
        arrest = build_arrest_event
        custody = OtherEvent.new(date: Date.today, counts: [], header: 'custody')

        rap_sheet = build_rap_sheet(events: [arrest, custody])
        expect(rap_sheet.arrests[0]).to eq arrest
      end
    end

    describe '#superstrikes' do
      it 'returns any superstrike convictions' do
        count = build_court_count(code: 'PC', section: '187', disposition: 'convicted')
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.superstrikes).to contain_exactly(count)
      end

      it 'returns empty list if no superstrike convictions' do
        count = build_court_count(code: 'PC', section: '187', disposition: 'dismissed')
        conviction = build_court_event(counts: [count])

        rap_sheet = build_rap_sheet(events: [conviction])
        expect(rap_sheet.superstrikes).to be_empty
      end
    end
    describe '#convictions' do
      it 'returns an array of convicted court events' do
        convicted_count = build_court_count(code: 'PC', section: '32', disposition: 'convicted')
        dismissed_count = build_court_count(code: 'HS', section: '11359', disposition: 'dismissed')
        court_event_1 = build_court_event(counts: [convicted_count])
        court_event_2 = build_court_event(counts: [dismissed_count])
        rap_sheet =  build_rap_sheet(events: [court_event_1, court_event_2, build_arrest_event])
        expect(rap_sheet.convictions).to contain_exactly(court_event_1)
      end
    end
  end
end
