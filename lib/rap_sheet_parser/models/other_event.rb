module RapSheetParser
  class OtherEvent
    def initialize(cycle_events: [], date:, counts:, header:)
      @cycle_events = cycle_events
      @date = date
      @counts = counts
      @header = header
    end

    attr_reader :cycle_events, :date, :counts, :header
  end
end
