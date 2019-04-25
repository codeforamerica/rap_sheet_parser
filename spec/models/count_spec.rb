require 'spec_helper'

RSpec.describe RapSheetParser::Count do
  describe '#superstrike?' do
    it 'returns true if code section is associated with superstrikes' do
      count = build_count(code: 'PC', section: '187')

      expect(count).to be_superstrike
    end

    it 'returns false if code section is subsection of a superstrike' do
      count = build_count(code: 'PC', section: '187(a)')

      expect(count).not_to be_superstrike
    end

    it 'returns false if no code section' do
      count = build_count(code: nil, section: nil)

      expect(count.superstrike?).to eq false
    end

    it 'returns false if code section is not associated with superstrikes' do
      count = build_count(code: 'PC', section: '11359')

      expect(count).not_to be_superstrike
    end

    it 'returns false if the count has an attempted flag' do
      count = build_count(code: 'PC', section: '269', flags: ['-ATTEMPTED'])

      expect(count).not_to be_superstrike
    end

    context 'the code is still a superstrike when it is attempted' do
      it 'returns true if code section is associated with superstrikes' do
        count = build_count(code: 'PC', section: '187', flags: ['-ATTEMPTED'])

        expect(count).to be_superstrike
      end
    end
  end

  describe '#subsection_of?' do
    it 'returns true if code sections are the same' do
      count = build_count(code: 'PC', section: '11359(a)')

      expect(count.subsection_of?('PC 11359')).to eq true
    end

    it 'returns true if code sections and specified subsection are the same' do
      count = build_count(code: 'PC', section: '11359(a)(b)')

      expect(count.subsection_of?('PC 11359(a)')).to eq true
    end

    it 'returns false if no code section' do
      count = build_count(code: nil, section: nil)

      expect(count.subsection_of?('PC 11359')).to eq false
    end

    it 'returns false for codes with different sections' do
      count = build_count(code: 'PC', section: '11359')

      expect(count.subsection_of?('PC 1135')).to eq false
    end
  end

  describe '#subsection_of_any?' do
    it 'returns true if any code sections in the list match' do
      count = build_count(code: 'PC', section: '11359(a)')

      expect(count.subsection_of_any?(['PC 11358', 'PC 11359', 'PC 445'])).to eq true
    end

    it 'returns false if no code section' do
      count = build_count(code: nil, section: nil)

      expect(count.subsection_of_any?(['PC 11358', 'PC 11359', 'PC 445'])).to eq false
    end

    it 'returns false if none of the code sections match' do
      count = build_count(code: 'PC', section: '11359')

      expect(count.subsection_of_any?(['PC 1135', 'PC 11359(b)', 'PC 445'])).to eq false
    end
  end

  describe '#sentence' do
    it'returns nil if dispositions is nil' do
      count = build_count(code: 'PC', section: '111', dispositions: nil)
      expect(count.sentence). to eq nil
    end
  end

  describe '#severity' do
    it'returns nil if dispositions is nil' do
      count = build_count(code: 'PC', section: '111', dispositions: nil)
      expect(count.severity). to eq nil
    end
  end
end
