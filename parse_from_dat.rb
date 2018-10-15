require 'csv'
require 'awesome_print'
require 'rap_sheet_parser'
require 'pry-byebug'

module RapSheetParser
  class DojDataParser
    def parse_from_dat(path)
      csv = CSV.read(path, headers: true)

      cycles = csv.group_by { |row| row['CYC_ORDER'] }

      RapSheet.new(cycles: parse_cycles(cycles), personal_info: nil)
    end

    private

    def parse_disposition(count_rows)
      disposition_line = count_rows.find do |row|
        row['DISP_ORDER'][9] == '2' if row['DISP_ORDER']
      end

      return unless disposition_line

      sentence = nil
      if disposition_line['SENT_ORDER']
        sentence_loc = disposition_line['SENT_LOC_DESCR'].downcase
        sentence_duration = {
          'D' => disposition_line['SENT_LENGTH'].to_i.days
        }[disposition_line['SENT_TIME_CODE']]

        sentence = ConvictionSentence.new(sentence_loc.to_sym => sentence_duration)
      end

      Disposition.new(type: disposition_line['DISP_CODE'],
                      sentence: sentence,
                      severity: disposition_line['OFFENSE_TOC'],
                      text: disposition_line['DISP_DESCR'])
    end

    def parse_counts(counts)
      counts.map do |_, rows|

        Count.new(code_section_description: rows[0]['OFFENSE_DESCR'],
                  code: rows[0]['OFFENSE_CODE'],
                  section: nil,
                  disposition: parse_disposition(rows),
                  updates: nil,
                  flags: nil)
      end
    end

    def parse_events(events)
      event_types = %w(unused arrest court)

      events.map do |_, rows|
        counts = rows.group_by { |row| row['CNT_ORDER'] }

        OtherEvent.new(date: rows[0]['STP_EVENT_DATE'],
                       counts: parse_counts(counts),
                       event_type: event_types[rows[0]['STP_ORI_TYPE'].to_i],
                       agency: rows[0]['STP_ORI_CODE'])
      end
    end

    def parse_cycles(cycles)
      cycles.map do |_, rows|
        events = rows.group_by { |row| row['STP_ORDER'] }

        Cycle.new(events: parse_events(events))
      end
    end
  end
end

sheet = RapSheetParser::DojDataParser.new.parse_from_dat('cadoj.csv')
pry
