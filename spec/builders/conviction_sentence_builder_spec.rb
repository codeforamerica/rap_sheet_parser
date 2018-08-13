require 'spec_helper'

module RapSheetParser
  RSpec.describe ConvictionSentenceBuilder do
    it 'parses jail time' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 006 MONTHS JAIL
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      subject = described_class.new(sentence_node).build
      expect(subject.jail).to eq 6.months
      expect(subject.probation).to eq nil
      expect(subject.prison).to eq nil
    end

    it 'parses probation time' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.probation).to eq 12.months
    end

    it 'parses missing probation time' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: PROBATION
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.probation).to eq 0.days
    end

    it 'parses prison time' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 YEARS PRISON
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.prison).to eq 12.years
    end

    it 'parses times from comments' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        COM: SEN-X24 MO PROB, 8 DS JL, RSTN
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      result = described_class.new(sentence_node).build
      expect(result.probation).to eq 24.months
      expect(result.jail).to eq 8.days

      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        COM: SEN-X3 YR PROB
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.probation).to eq 3.years
    end

    it 'downcases details' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 YEARS PRISON, FINE, FINE SS
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.to_s).to eq('12y prison, fine, fine ss')
    end

    it 'standardizes restitution strings' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: RESTN, RSTN, RESTITUTION
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.to_s).to eq('restitution, restitution, restitution')
    end

    it 'cleans up common strings' do
      text = <<~TEXT
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: BL FINE SS AH, CONCURRENT B A
      TEXT

      count = CountGrammarParser.new.parse(text)
      sentence_node = count.disposition.sentence
      expect(described_class.new(sentence_node).build.to_s).to eq('fine ss, concurrent')
    end
  end
end
