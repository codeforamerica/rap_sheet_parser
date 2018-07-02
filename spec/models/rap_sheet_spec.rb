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
        arrest = ArrestEvent.new(date: Date.today)
        custody = CustodyEvent.new(date: Date.today)

        rap_sheet = build_rap_sheet(events: [arrest, custody])
        expect(rap_sheet.arrests[0]).to eq arrest
      end
    end
  end
end
