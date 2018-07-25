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

    def conviction_event(event)
      event.is_a?(EventGrammar::CourtEvent) && event.is_conviction?
    end

    def events
      @parsed_rap_sheet.cycles.flat_map do |cycle_syntax_node|
        cycle_events = []
        cycle_syntax_node.events.each do |event_syntax_node|
          if event_syntax_node.is_a? EventGrammar::Event
            cycle_events.push(event_for_node(cycle_events, event_syntax_node))
          else
            @logger.warn('Unrecognized event:')
            @logger.warn(event_syntax_node.text_value)
            nil
          end
        end
        cycle_events
      end.compact
    end

    def event_for_node(cycle_events, event_syntax_node)
      builder_class = event_builder_class_for_node(event_syntax_node)
      builder_class&.new(
        event_syntax_node,
        cycle_events: cycle_events,
        logger: @logger
      )&.build
    end

    def event_builder_class_for_node(event_syntax_node)
      if conviction_event(event_syntax_node)
        ConvictionEventBuilder
      elsif event_syntax_node.is_a? EventGrammar::ArrestEvent
        ArrestEventBuilder
      elsif event_syntax_node.is_a? EventGrammar::CustodyEvent
        CustodyEventBuilder
      elsif event_syntax_node.is_a? EventGrammar::RegistrationEvent
        RegistrationEventBuilder
      end
    end

    def personal_info
      PersonalInfoBuilder.new(@parsed_rap_sheet.personal_info).build
    end
  end
end

