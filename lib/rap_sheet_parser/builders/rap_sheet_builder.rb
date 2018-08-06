module RapSheetParser
  class RapSheetBuilder
    def initialize(parsed_rap_sheet, logger:)
      @parsed_rap_sheet = parsed_rap_sheet
      @logger = logger
    end

    def build
      RapSheet.new(events: events, personal_info: personal_info)
    end

    private

    def known_events_for_cycle(cycle_syntax_node)
      cycle_syntax_node.events.select do |event_syntax_node|
        if event_syntax_node.is_a? EventGrammar::Event
          true
        else
          @logger.warn('Unrecognized event:')
          @logger.warn(event_syntax_node.text_value)
          false
        end
      end
    end

    def events
      @parsed_rap_sheet.cycles.flat_map do |cycle_syntax_node|
        known_events = known_events_for_cycle(cycle_syntax_node)

        cycle_events = []

        known_events.each do |event_syntax_node|
          cycle_events.push(event_for_node(cycle_events, event_syntax_node))
        end

        cycle_events
      end.compact
    end

    def event_for_node(cycle_events, event_syntax_node)
      builder_class = event_builder_class_for_node(event_syntax_node)
      builder_class.new(
        event_syntax_node,
        cycle_events: cycle_events,
        logger: @logger
      ).build
    end

    def event_builder_class_for_node(event_syntax_node)
      event_identifier = event_syntax_node.event_identifier

      if event_identifier.is_a? EventGrammar::CourtEventIdentifier
        CourtEventBuilder
      elsif event_identifier.is_a? EventGrammar::ArrestEventIdentifier
        ArrestEventBuilder
      elsif event_identifier.is_a? EventGrammar::CustodyEventIdentifier
        CustodyEventBuilder
      elsif event_identifier.is_a? EventGrammar::RegistrationEventIdentifier
        RegistrationEventBuilder
      end
    end

    def personal_info
      PersonalInfoBuilder.new(@parsed_rap_sheet.personal_info).build
    end
  end
end

