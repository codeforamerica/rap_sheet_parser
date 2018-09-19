module RapSheetParser
  class OtherEventBuilder
    include EventBuilder

    def build
      built_counts = counts
      logger.warn("Detected #{header} event with dispo convicted") if built_counts.any? { |count| count.disposition&.type == 'convicted' }

      OtherEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: built_counts,
        header: header,
        agency: agency
      )
    end

    private

    def header
      event_syntax_node.event_identifier.class.name.demodulize.underscore.gsub('_event_identifier', '')
    end
  end
end
