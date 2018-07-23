require 'spec_helper'

module RapSheetParser
  RSpec.describe RegistrationEventBuilder do

    it 'populates updates' do
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
      logger = Logger.new(log)

      build(text, logger)

      expect(log.string).to include('Update on registration event:')
      expect(log.string).to include('DISPO:NO LONGER REQUIRED TO REGISTER/DRUG REG')
    end

    def build(text, logger)
      tree = RapSheetGrammarParser.new.parse(text)
      described_class.new(tree.cycles[0].events[0], logger: logger).build
    end
  end
end