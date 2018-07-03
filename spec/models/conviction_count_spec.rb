require 'spec_helper'

RSpec.describe RapSheetParser::ConvictionCount do
  describe '#superstrike?' do
    it 'returns true if code section is associated with superstrikes' do
      count = described_class.new(
        code: 'PC',
        section: '187',
        severity: nil,
        code_section_description: nil
      )

      expect(count).to be_superstrike
    end

    it 'returns false if code section is subsection of a superstrike' do
      count = described_class.new(
        code: 'PC',
        section: '187(a)',
        severity: nil,
        code_section_description: nil
      )

      expect(count).not_to be_superstrike
    end

    it 'returns false if no code section' do
      count = described_class.new(
        code: nil,
        section: nil,
        severity: nil,
        code_section_description: nil
      )

      expect(count.superstrike?).to eq false
    end
    
    it 'returns false if code section is not associated with superstrikes' do
      count = described_class.new(
        code: 'PC',
        section: '11359',
        severity: nil,
        code_section_description: nil
      )

      expect(count).not_to be_superstrike
    end
  end

  describe '#code_section_starts_with' do
    it 'returns true if the count code section starts with specified codes' do
      count = described_class.new(
        code: 'PC',
        section: '11359(a)',
        severity: nil,
        code_section_description: nil
      )

      expect(count.code_section_starts_with(['PC 11359'])).to eq true
    end

    it 'returns false if no code section' do
      count = described_class.new(
        code: nil,
        section: nil,
        severity: nil,
        code_section_description: nil
      )

      expect(count.code_section_starts_with(['PC 11359'])).to eq false
    end
  end
end
