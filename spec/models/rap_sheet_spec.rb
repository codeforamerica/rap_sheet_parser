require 'spec_helper'

module RapSheetParser
  RSpec.describe RapSheet do
    describe 'sex_offender_registration?' do
      it 'returns true if registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'PC 290'
        )

        rap_sheet = described_class.new([event])
        
        expect(rap_sheet.sex_offender_registration?).to eq true
      end
      
      it 'returns false if no registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'HS 11590'
        )
        rap_sheet = described_class.new([event])
        
        expect(rap_sheet.sex_offender_registration?).to eq false
        end
      
      it 'returns false if no registration event containing PC 290' do
        event = RegistrationEvent.new(
          date: nil,
          code_section: 'HS 11590'
        )
        rap_sheet = described_class.new([event])
        
        expect(rap_sheet.sex_offender_registration?).to eq false
        expect(rap_sheet.narcotics_offender_registration?).to eq true
      end
    end
  end
end
