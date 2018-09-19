module RapSheetParser
  class OtherEvent
    def initialize(cycle_events: [], date:, counts:, event_type:, agency:)
      @cycle_events = cycle_events
      @date = date
      @counts = counts
      @event_type = event_type
      @agency = agency
    end

    attr_reader :cycle_events, :date, :counts, :event_type, :agency
  end
end
