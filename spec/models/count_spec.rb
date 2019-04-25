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

  describe '#match_any' do
    let(:count) { build_count(code: 'PC', section: '11359(a)') }
    context 'include_subsections is true' do
      it 'returns true if the code section is a subsection or exact match for one of the inputs' do
        expect(count.match_any?(['PC 11358', 'PC 11359', 'PC 445'], subsections: true)).to eq true
        expect(count.match_any?(['PC 11358', 'PC 11359(a)', 'PC 445'], subsections: true)).to eq true
      end

      it 'returns false if the code section is not a subsection or exact match for one of the inputs' do
        expect(count.match_any?(['PC 11359(a)(4)', 'PC 11359(b)', 'PC 445'], subsections: true)).to eq false
      end
    end

    context 'include_subsections is false' do
      it 'returns true if the code section is an exact match for one of the inputs' do
        expect(count.match_any?(['PC 11358', 'PC 11359(a)', 'PC 445'], subsections: false)).to eq true
      end

      it 'returns false if the code section is not an exact match for one of the inputs' do
        expect(count.match_any?(['PC 11359(a)(4)', 'PC 11359', 'PC 445'], subsections: false)).to eq false
      end
    end

    context 'include_subsections not specified' do
      it 'defaults to including subsections' do
        expect(count.match_any?(['PC 11358', 'PC 11359', 'PC 445'])).to eq true
        expect(count.match_any?(['PC 11358', 'PC 11359(a)', 'PC 445'])).to eq true
        expect(count.match_any?(['PC 11359(a)(4)', 'PC 11359(b)', 'PC 445'])).to eq false
      end
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
