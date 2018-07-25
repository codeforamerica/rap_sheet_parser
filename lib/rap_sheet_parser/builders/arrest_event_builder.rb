module RapSheetParser
  class ArrestEventBuilder
    include EventBuilder

    def build
      ArrestEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: counts
      )
    end
  end
end
