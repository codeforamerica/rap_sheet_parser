module RapSheetParser
  class OtherEvent
    def initialize(cycle_events: [], date:, counts:, header:, agency:)
      @cycle_events = cycle_events
      @date = date
      @counts = counts
      @header = header
      @agency = agency
    end

    attr_reader :cycle_events, :date, :counts, :header, :agency
  end
end
