require 'spec_helper'

module RapSheetParser
  RSpec.describe DateBuilder do
    it 'creates dates from date strings' do
      date = build_date('19820102')
      expect(date).to eq Date.new(1982, 1, 2)
    end

    it 'returns nil for invalid date strings' do
      date = build_date('19820002')
      expect(date).to eq nil
    end

    it 'strips stray periods from date' do
      date = build_date('198201.02')
      expect(date).to eq Date.new(1982, 1, 2)
    end

    def build_date(text)
      date_syntax_node = double(text_value: text)
      described_class.new(date_syntax_node).build
    end
  end
end
