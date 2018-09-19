module RapSheetParser
  class OtherEventBuilder
    include EventBuilder

    def build
      built_counts = counts
      logger.warn("Detected #{event_type} event with dispo convicted") if built_counts.any? { |count| count.disposition&.type == 'convicted' }

      OtherEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: built_counts,
        event_type: event_type,
        agency: agency
      )
    end

    private

    def event_type
      event_syntax_node.event_identifier.class.name.demodulize.underscore.gsub('_event_identifier', '')
    end
  end
end
