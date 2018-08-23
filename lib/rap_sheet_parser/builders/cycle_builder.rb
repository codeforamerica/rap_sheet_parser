module RapSheetParser
  class CycleBuilder
    def initialize(cycle_node, logger:)
      @cycle_node = cycle_node
      @logger = logger
    end

    def build
      Cycle.new(events: events)
    end

    private

    def events
      cycle_events = []

      known_events.each do |event_syntax_node|
        cycle_events.push(event_for_node(cycle_events, event_syntax_node))
      end
      cycle_events
    end

    def known_events
      @cycle_node.events.select do |event_syntax_node|
        if event_syntax_node.is_a? EventGrammar::Event
          true
        else
          @logger.warn('Unrecognized event:')
          @logger.warn(event_syntax_node.text_value)
          false
        end
      end
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
      elsif event_identifier.is_a? EventGrammar::RegistrationEventIdentifier
        RegistrationEventBuilder
      else
        OtherEventBuilder
      end
    end
  end
end
