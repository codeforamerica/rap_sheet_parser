module RapSheetParser
  class ArrestEvent
    def initialize(cycle_events: [], date:, counts:)
      @cycle_events = cycle_events
      @date = date
      @counts = counts
    end

    attr_reader :cycle_events, :date, :counts

    def inspect
      OkayPrint.new(self).exclude_ivars(:@counts).inspect
    end
  end
end
