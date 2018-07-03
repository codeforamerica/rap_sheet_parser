require 'spec_helper'

module RapSheetParser
  RSpec.describe ArrestEventBuilder do
    it 'populates arrest event' do
      text = <<~TEXT
        info
        * * * *
        ARR/DET/CITE:
        NAM:001
        19910105 CAPD CONCORD
        TOC:F
        CNT:001
        #65131
        496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        * * * END OF MESSAGE * * *
      TEXT

      tree = RapSheetGrammarParser.new.parse(text)
      event_node = tree.cycles[0].events[0]

      subject = described_class.new(event_node, logger: nil).build

      expect(subject).to be_a ArrestEvent
      expect(subject.date).to eq Date.new(1991, 1, 5)
    end
  end
end
