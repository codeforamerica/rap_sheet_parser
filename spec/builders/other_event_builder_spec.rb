require 'spec_helper'

module RapSheetParser
  RSpec.describe OtherEventBuilder do
    it 'populates arrest event' do
      text = <<~TEXT
        ARR/DET/CITE:
        NAM:001
        19910105 CAPD CONCORD
        TOC:F
        CNT:001
        #65131
        496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      TEXT

      event_node = OtherCycleEventGrammarParser.new.parse(text)
      subject = described_class.new(event_node, logger: nil).build

      expect(subject).to be_a OtherEvent
      expect(subject.header).to eq 'arrest'
      expect(subject.date).to eq Date.new(1991, 1, 5)
      expect(subject.agency).to eq 'CAPD CONCORD'
    end

    it 'displays warning if event has a disposition convicted' do
      text = <<~TEXT
        CUSTODY:
        NAM:001
        19910105 CAPD CONCORD
        TOC:F
        CNT:001
        #65131
        496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        DISPO:CONVICTED
      TEXT

      log = StringIO.new
      logger = Logger.new(log)
      event_node = OtherCycleEventGrammarParser.new.parse(text)
      described_class.new(event_node, logger: logger).build

      expect(log.string).to include 'WARN -- : Detected custody event with dispo convicted'
    end
  end
end
