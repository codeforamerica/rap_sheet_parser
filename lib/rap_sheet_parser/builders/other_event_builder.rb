module RapSheetParser
  class OtherEventBuilder
    include EventBuilder

    def build
      OtherEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: counts,
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
