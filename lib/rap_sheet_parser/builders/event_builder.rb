require 'date'

module RapSheetParser
  module EventBuilder
    def initialize(event_syntax_node, cycle_events: nil, logger:)
      @cycle_events = cycle_events
      @event_syntax_node = event_syntax_node
      @logger = logger
    end

    attr_reader :cycle_events

    private

    attr_reader :event_syntax_node, :logger

    def counts
      event_syntax_node.counts.map do |count|
        num_counts(count).times.map do |_|
          CourtCountBuilder.new(count, logger: logger).build
        end
      end.flatten
    end

    def num_counts(count)
      if count.count_identifier.end_number.text_value.present?
        1 + count.count_identifier.end_number.text_value.to_i - count.count_identifier.start_number.text_value.to_i
      else
        1
      end
    end

    def date
      Date.strptime(date_string, '%Y%m%d')
    rescue ArgumentError
      nil
    end

    def date_string
      event_syntax_node.date.text_value.
        gsub('.', '')
    end
  end
end
