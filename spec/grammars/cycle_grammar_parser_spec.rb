require 'spec_helper'

module RapSheetParser
  RSpec.describe CycleGrammarParser do
    describe '#parse' do
      def subject(text)
        text_with_personal_info = <<~TEXT
          arbitrary
          * * * *
          #{text.strip}
        TEXT

        RapSheetGrammarParser.new.parse(text_with_personal_info).cycles[0].events
      end

      it 'parses one event' do
        text = <<~TEXT
          event one text
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq "event one text\n"
      end

      it 'parses many events' do
        text = <<~TEXT
          event one text
          - - - -
          another event
          with multiple lines
          - - - -
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "another event\nwith multiple lines"
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'parses many events when the cycle delimiters have extra dashes' do
        text = <<~TEXT
          event one text
          - - -- --
          another event
          --- - ---
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq 'another event'
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'parses many events when the cycle delimiters have stray quotes' do
        text = <<~TEXT
          event one text
          - '- -- --
          another event
          --- - ---
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq 'another event'
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'parses many events when court event has missing event delimiter' do
        text = <<~TEXT
          event one text
          COURT:
          another event
          --- - ---
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "COURT:\nanother event"
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'parses many events when arrest event has missing event delimiter' do
        text = <<~TEXT
          event one text
          ARR/DET/CITE:
          another event
          --- - ---
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "ARR/DET/CITE:\nanother event"
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'handles when court event has extra whitespace' do
        text = <<~TEXT
          event one text
          COURT :
          another event
          --- - ---
          more events
        TEXT

        events = subject(text)
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "COURT :\nanother event"
        expect(events[2].text_value).to eq "more events\n"
      end

      it 'handles stray dashes in event' do
        text = <<~TEXT
          event
          -
          one text
          - - -- --
          another event
        TEXT

        events = subject(text)
        expect(events.length).to eq 2
        expect(events[0].text_value).to eq "event\n-\none text"
        expect(events[1].text_value).to eq "another event\n"
      end

      it 'parses multiple events with trailing felony strike section' do
        text = <<~TEXT
          event
          * * * * * * * * * * *
          ** POTENTIAL FELONY STRIKE ENTRY   **
          * * * * * * * * * * *

          - - - -
          another event
        TEXT

        events = subject(text)
        expect(events.length).to eq 2
        expect(events[0].text_value).to eq "event\n"
        expect(events[1].text_value).to eq "another event\n"
      end

      it 'parses events with trailing felony strike section' do
        text = <<~TEXT
          event
          * * * * * * * * * * *
          ** POTENTIAL FELONY STRIKE ENTRY   **
          * * * * * * * * * * *

        TEXT

        events = subject(text)
        expect(events.length).to eq 1
        expect(events[0].text_value).to eq "event\n"
      end
    end
  end
end
