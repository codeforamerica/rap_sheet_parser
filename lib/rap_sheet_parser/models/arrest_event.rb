module RapSheetParser
  class ArrestEvent
    def initialize(cycle_events: [], date:, counts:, agency:)
      @cycle_events = cycle_events
      @date = date
      @counts = counts
      @agency = agency
    end

    attr_reader :cycle_events, :date, :counts, :agency

    def inspect
      OkayPrint.new(self).exclude_ivars(:@counts).inspect
    end
  end
end
