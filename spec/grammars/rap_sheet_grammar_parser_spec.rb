require 'spec_helper'

module RapSheetParser
  RSpec.describe RapSheetGrammarParser do
    describe '#parse' do
      subject { described_class.new.parse(text) }

      context 'parsing personal info' do
        let(:text) { <<~TEXT }
          bla bla
          CII/A01234557
          DOB/19681122    SEX/M  RAC/WHITE
          HGT/511  WGT/265  EYE/BLU  HAI/BRO  POB/CA
          NAM/01 LAST, FIRST
          02 NAME, BOB
          FBI/7778889LA2
          CDL/C45667234 C14546456
          SOC/549377146
          OCC/CONCRET
          * * * *
          cycle text
          * * * END OF MESSAGE * * *
        TEXT

        it 'parses values in personal info' do
          expect(subject.personal_info).to be_a(RapSheetGrammar::PersonalInfo)
          expect(subject.personal_info.sex.sex_value.text_value).to eq 'M'
          expect(subject.personal_info.cii.cii_value.text_value).to eq 'A01234557'
          expect(subject.personal_info.names[0].text_value).to eq '01 LAST, FIRST'
          expect(subject.personal_info.names[1].text_value).to eq '02 NAME, BOB'
          expect(subject.personal_info.date_of_birth.date.text_value).to eq '19681122'
          expect(subject.personal_info.race.race_value.text_value).to eq "WHITE\n"
        end
      end

      context 'when we are missing personal info' do
        let(:text) { <<~TEXT }
          la la la
          * * * *
          cycle text
          * * * END OF MESSAGE * * *
        TEXT

        it 'parses personal info' do
          expect(subject.personal_info).to be_a(Unknown)
          expect(subject.cycles.length).to eq 1
        end
      end

      context 'fails to parse if zero cycles' do
        let(:text) { <<~TEXT }
          la la la
          * * * END OF MESSAGE * * *
        TEXT

        it 'does not parse' do
          expect(subject).to be_nil
        end
      end

      context 'record error' do
        let(:text) { <<~TEXT }
          some personal info
          * * *   * * *
          RECORD ERROR - REFER TO CRIMINAL HISTORY INQUIRY MANUAL
          * * * END OF MESSAGE * * *
        TEXT

        it 'does not parse' do
          expect(subject).to be_nil
        end
      end

      context 'parsing multiple cycles' do
        let(:text) { <<~TEXT }
          super
          arbitrary

          * * * *
          cycle text
          * * * *
          another cycle text
          * * * *
          REGISTRATION:
          hi i am registered
          * * * END OF MESSAGE * * *
        TEXT

        it 'parses cycles to their correct type' do
          expect(subject.cycles[0].cycle_content).to be_a RapSheetGrammar::CycleContent
          expect(subject.cycles[0].cycle_content.text_value).to eq('cycle text')
          expect(subject.cycles[1].cycle_content).to be_a RapSheetGrammar::CycleContent
          expect(subject.cycles[1].cycle_content.text_value).to eq('another cycle text')
          expect(subject.cycles[2].cycle_content).to be_a RapSheetGrammar::RegistrationCycleContent
          expect(subject.cycles[2].cycle_content.text_value).to eq("REGISTRATION:\nhi i am registered")
        end
      end

      context 'registration cycle with multiple events' do
        let(:text) { <<~TEXT }
          super
          arbitrary
          * * * *
          REGISTRATION:

          19960101

          CNT:01 #ABCDE
            11590 HS-REGISTRATION OF CNTL SUB OFFENDER
          - - - -
          20030101

          CNT:01 #EFHIHJ
            290 PC-PREREGISTRATION OF SEX OFFENDER
        TEXT

        it "can parse out many registration events even though they don't all have the word REGISTRATION in them" do
          events = subject.cycles[0].events
          expect(events.length).to eq 2
          expect(events[0]).to be_a(EventGrammar::Event)
          expect(events[0].event_identifier).to be_a(EventGrammar::RegistrationEventIdentifier)
          expect(events[1]).to be_a(EventGrammar::Event)
          expect(events[1].event_identifier).to be_a(EventGrammar::RegistrationEventIdentifier)
        end
      end

      it 'parses extra periods and commas in cycle delimiter' do
        text = <<~TEXT
          super
          arbitrary

            .   * *, * *.
          cycle text
          .,* * ·* * .
          another cycle text
          * * * END OF MESSAGE * * *
        TEXT

        cycles = described_class.new.parse(text).cycles

        expect(cycles[0].cycle_content.text_value).to eq('cycle text')
        expect(cycles[1].cycle_content.text_value).to eq('another cycle text')
      end

      it 'parses newlines between asterisks in cycle delimiter' do
        text = <<~TEXT
          super
          arbitrary
          *
          *
          *
          *
          cycle text
          * * * *
          another cycle text
          * * * END OF MESSAGE * * *
        TEXT

        cycles = described_class.new.parse(text).cycles

        expect(cycles[0].cycle_content.text_value).to eq('cycle text')
        expect(cycles[1].cycle_content.text_value).to eq('another cycle text')
      end

      it 'allows for arbitrary number of asterisks before end of message' do
        text = <<~TEXT
          arbitrary

          * * * *
          cycle text
          * END OF MESSAGE.
          some stuff
        TEXT

        expect(described_class.new.parse(text)).not_to be_nil
      end

      it 'correctly parses personal info that has more than 4 asterisks' do
        text = <<~TEXT
          blah blah
          *********************
          blah blah
          * * * *
          cycle 1
        TEXT

        subject = described_class.new.parse(text)
        expect(subject.personal_info.text_value).to eq "blah blah\n*********************\nblah blah"
        expect(subject.cycles[0].cycle_content.text_value).to eq("cycle 1\n")
      end

      it 'allows for missing end of message' do
        text = <<~TEXT
          arbitrary

          * * * *
          cycle text
          * * * *
          another cycle text
        TEXT

        cycles = described_class.new.parse(text).cycles

        expect(cycles[0].cycle_content.text_value).to eq('cycle text')
        expect(cycles[1].cycle_content.text_value).to eq("another cycle text\n")
      end

      describe 'parsing events from cycles' do
        let(:text) { <<~TEXT }
          hello

          * * * *
          event 1
          - - - -
          event 2
          * * * *
          event 3
          - - - -
          event 4
          * * * END OF MESSAGE * * *
        TEXT

        it 'has an events method that calls the cycle parser' do
          result = subject.cycles
          expect(result.length).to eq 2
          cycle1 = result[0]
          cycle2 = result[1]
          expect(cycle1.events[0].text_value).to eq 'event 1'
          expect(cycle1.events[1].text_value).to eq 'event 2'
          expect(cycle2.events[0].text_value).to eq 'event 3'
          expect(cycle2.events[1].text_value).to eq 'event 4'
        end
      end
    end
  end
end
