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

  describe '#code_section_starts_with' do
    it 'returns true if the count code section starts with specified codes' do
      count = build_court_count(code: 'PC', section: '11359(a)')

      expect(count.code_section_starts_with(['PC 11359'])).to eq true
    end

    it 'returns false if no code section' do
      count = build_court_count(code: nil, section: nil)

      expect(count.code_section_starts_with(['PC 11359'])).to eq false
    end
  end

  describe 'severity filters' do
    xit 'can filter counts by severity strings' do
      count_1 = build_court_count(severity: 'F')
      count_2 = build_court_count(severity: 'M')
      count_3 = build_court_count(severity: nil)

      subject = build_court_event(counts: [count_1, count_2, count_3]).counts

      expect(subject.severity_felony).to eq [count_1]
      expect(subject.severity_misdemeanor).to eq [count_2]
      expect(subject.severity_unknown).to eq [count_3]
    end
  end
end
