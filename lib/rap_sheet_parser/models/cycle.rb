module RapSheetParser
  class Cycle
    attr_reader :events

    def initialize(events:)
      @events = events
    end
  end
end
