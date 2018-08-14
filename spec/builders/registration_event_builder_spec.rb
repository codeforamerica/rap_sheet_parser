require 'spec_helper'

module RapSheetParser
  RSpec.describe RegistrationEventBuilder do
    it 'populates a registration event' do
      text = <<~TEXT
        info
        * * * *
        REGISTRATION: NAME7OZ
        19800101 CAMC LOS ANGELES METRO

        CNT:01     #111222
          11590 HS-REGISTRATION OF CNTL SUB OFFENDER

        19820101
         DISPO:NO LONGER REQUIRED TO REGISTER/DRUG REG
        * * * END OF MESSAGE * * *
      TEXT

      log = StringIO.new
      registration_event = build(text, Logger.new(log))

      expect(registration_event.date).to eq Date.new(1980, 1, 1)

      expect(log.string).to include('Update on registration event:')
      expect(log.string).to include('DISPO:NO LONGER REQUIRED TO REGISTER/DRUG REG')
    end

    def build(text, logger)
      tree = RapSheetGrammarParser.new.parse(text)
      described_class.new(tree.cycles[0].events[0], logger: logger).build
    end
  end
end
