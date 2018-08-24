require 'spec_helper'

module RapSheetParser
  RSpec.describe RegistrationCycleEventGrammarParser do
    describe '#parse' do
      context 'parsing a registration event' do
        it 'parses' do
          text = <<~TEXT
            REGISTRATION:         NAM:01
            20171216 CASO SAN DIEGO
            CNT:01
              290 PC-REGISTRATION OF SEX OFFENDER
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(RegistrationCycleEventGrammar::RegistrationEventIdentifier)
          expect(subject.date.text_value).to eq '20171216'
          expect(subject.courthouse.text_value).to eq 'CASO SAN DIEGO'
          expect(subject.counts.length).to eq 1
          expect(subject.counts[0].code_section.text_value).to eq '290 PC'
        end

        it 'parses with optional registration header' do
          text = <<~TEXT
            20171216 CASO SAN DIEGO
            CNT:01
              290 PC-REGISTRATION OF SEX OFFENDER
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(RegistrationCycleEventGrammar::RegistrationEventIdentifier)
          expect(subject.date.text_value).to eq '20171216'
          expect(subject.courthouse.text_value).to eq 'CASO SAN DIEGO'
          expect(subject.counts.length).to eq 1
          expect(subject.counts[0].code_section.text_value).to eq '290 PC'
        end

        it 'parses registration events that have updates' do
          text = <<~TEXT
            REGISTRATION:         NAM:01
            20171216 CASO SAN DIEGO
            CNT:01
              290 PC-REGISTRATION OF SEX OFFENDER

            20180101
            DISPO:NO LONGER REQUIRED TO REGISTER/DRUG REG
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(RegistrationCycleEventGrammar::RegistrationEventIdentifier)
          expect(subject.date.text_value).to eq '20171216'
          expect(subject.courthouse.text_value).to eq 'CASO SAN DIEGO'
          expect(subject.counts.length).to eq 1
          expect(subject.counts[0].code_section.text_value).to eq '290 PC'
          expect(subject.updates[0].dispositions[0].text_value).to eq "DISPO:NO LONGER REQUIRED TO REGISTER/DRUG REG\n\n"
        end
      end
    end

    def parse(text)
      described_class.new.parse(text)
    end
  end
end
