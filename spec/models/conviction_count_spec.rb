require 'spec_helper'
require 'rap_sheet_parser'

RSpec.describe RapSheetParser::ConvictionCount do
  describe '#superstrike?' do
    it 'returns true if code section is associated with superstrikes' do
      count = described_class.new(
        code: 'PC',
        section: '187',
        severity: nil,
        code_section_description: nil,
        event: nil
      )

      expect(count).to be_superstrike
    end

    it 'returns true if code section is subsection of a superstrike' do
      count = described_class.new(
        code: 'PC',
        section: '187(a)',
        severity: nil,
        code_section_description: nil,
        event: nil
      )

      expect(count).to be_superstrike
    end

    it 'returns false if code section is not associated with superstrikes' do
      count = described_class.new(
        code: 'PC',
        section: '11359',
        severity: nil,
        code_section_description: nil,
        event: nil
      )

      expect(count).not_to be_superstrike
    end
  end
end
