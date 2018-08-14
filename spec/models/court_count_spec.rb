require 'spec_helper'

RSpec.describe RapSheetParser::CourtCount do
  describe '#superstrike?' do
    it 'returns true if code section is associated with superstrikes' do
      count = build_court_count(code: 'PC', section: '187')

      expect(count).to be_superstrike
    end

    it 'returns false if code section is subsection of a superstrike' do
      count = build_court_count(code: 'PC', section: '187(a)')

      expect(count).not_to be_superstrike
    end

    it 'returns false if no code section' do
      count = build_court_count(code: nil, section: nil)

      expect(count.superstrike?).to eq false
    end

    it 'returns false if code section is not associated with superstrikes' do
      count = build_court_count(code: 'PC', section: '11359')

      expect(count).not_to be_superstrike
    end
  end

  describe '#subsection_of?' do
    it 'returns true if code sections the same' do
      count = build_court_count(code: 'PC', section: '11359(a)')

      expect(count.subsection_of?(['PC 11359'])).to eq true
    end

    it 'returns true if code sections and specified subsection same' do
      count = build_court_count(code: 'PC', section: '11359(a)(b)')

      expect(count.subsection_of?(['PC 11359(a)'])).to eq true
    end

    it 'returns false if no code section' do
      count = build_court_count(code: nil, section: nil)

      expect(count.subsection_of?(['PC 11359'])).to eq false
    end

    it 'returns false for codes with different sections' do
      count = build_court_count(code: 'PC', section: '11359')

      expect(count.subsection_of?(['PC 1135'])).to eq false
    end
  end
end
