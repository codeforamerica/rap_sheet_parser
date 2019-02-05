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

  describe '#dui?' do
    it 'returns true if code section is a dui' do
      count = build_count(code: 'VC', section: '23152')

      expect(count.dui?).to eq true
    end

    it 'returns true if code section is a dui subsection' do
      count = build_count(code: 'VC', section: '23152(a)')

      expect(count.dui?).to eq true
    end

    it 'returns false if code section is not a dui' do
      count = build_count(code: 'VC', section: '23155')

      expect(count.dui?).to eq false
    end
  end

  describe '#subsection_of?' do
    it 'returns true if code sections the same' do
      count = build_count(code: 'PC', section: '11359(a)')

      expect(count.subsection_of?(['PC 11359'])).to eq true
    end

    it 'returns true if code sections and specified subsection same' do
      count = build_count(code: 'PC', section: '11359(a)(b)')

      expect(count.subsection_of?(['PC 11359(a)'])).to eq true
    end

    it 'returns false if no code section' do
      count = build_count(code: nil, section: nil)

      expect(count.subsection_of?(['PC 11359'])).to eq false
    end

    it 'returns false for codes with different sections' do
      count = build_count(code: 'PC', section: '11359')

      expect(count.subsection_of?(['PC 1135'])).to eq false
    end
  end
end
