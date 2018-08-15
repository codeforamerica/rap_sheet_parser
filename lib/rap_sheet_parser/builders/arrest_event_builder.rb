module RapSheetParser
  class ArrestEventBuilder
    include EventBuilder

    def build
      ArrestEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: counts,
        agency: agency
      )
    end

    private

    def agency
      event_syntax_node.courthouse.text_value
    end
  end
end
