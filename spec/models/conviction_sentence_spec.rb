require 'spec_helper'

module RapSheetParser
  RSpec.describe ConvictionSentence do
    describe '#total_duration' do
      it 'computes duration of both jail, prison, and probation periods' do
        expect(described_class.new(jail: 1.year).total_duration).to eq(1.year)
        expect(described_class.new(probation: 30.days).total_duration).to eq(30.days)
        expect(described_class.new(prison: 2.years).total_duration).to eq(2.years)
        expect(described_class.new(jail: 1.year, prison: 2.years, probation: 6.months).total_duration).to eq(3.years + 6.months)
      end
    end

    describe '#to_s' do
      it 'transforms probation, prison, and jail into strings and shows details' do
        result = described_class.new(
          jail: 6.months,
          prison: 10.years,
          probation: 2.days,
          details: ['fine']
        ).to_s
        expect(result).to eq('10y prison, 2d probation, 6m jail, fine')
      end

      it 'returns jail for missing jail durations' do
        result = described_class.new(jail: 0.seconds).to_s
        expect(result).to eq('jail')
      end
    end
  end
end
