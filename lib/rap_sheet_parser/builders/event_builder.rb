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
        Array.new(num_counts(count)) do |_|
          CountBuilder.new(count, event_date: date, logger: logger).build
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
      DateBuilder.new(event_syntax_node.date).build
    end

    def agency
      event_syntax_node.courthouse.text_value
    end
  end
end
