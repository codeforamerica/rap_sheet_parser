require 'date'

module RapSheetParser
  module EventBuilder
    def initialize(event_syntax_node, logger:)
      @event_syntax_node = event_syntax_node
      @logger = logger
    end

    private

    attr_reader :event_syntax_node, :logger

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
