require 'spec_helper'

module RapSheetParser
  RSpec.describe DispositionBuilder do
    describe '.build' do
      it 'builds disposition from treetop node' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        count_node = CountGrammarParser.new.parse(text)

        disposition = described_class.new(count_node.disposition, date: Date.new(1998, 0o3, 25), logger: nil).build

        expect(disposition.type).to eq 'convicted'
        expect(disposition.sentence.to_s).to eq '12m probation, 45d jail'
        expect(disposition.text).to eq 'DISPO:CONVICTED'
        expect(disposition.severity).to eq('M')
        expect(disposition.date).to eq(Date.new(1998, 0o3, 25))
      end

      it 'builds disposition when sentence is nil' do
        text = <<~TEXT
          11360(A) HS-SELL/FURNISH/ETC MARIJUANA/HASH
          DISPO:DISMISSED/FURTHERANCE OF JUSTICE
        TEXT

        count_node = CountGrammarParser.new.parse(text)

        disposition = described_class.new(count_node.disposition, date: nil, logger: nil).build

        expect(disposition.type).to eq 'dismissed'
        expect(disposition.sentence).to eq nil
        expect(disposition.text).to eq 'DISPO:DISMISSED/FURTHERANCE OF JUSTICE'
        expect(disposition.severity).to eq nil
      end
    end
  end
end
