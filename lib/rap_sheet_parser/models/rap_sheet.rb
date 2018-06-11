module RapSheetParser
  class RapSheet
    attr_reader :events
    
    def initialize(events)
      @events = events
    end
    
    def convictions
      filtered_events(ConvictionEvent)
    end

    def arrests
      filtered_events(ArrestEvent)
    end

    def custody_events
      filtered_events(CustodyEvent)
    end
    
    private
    
    def filtered_events(klass)
      events.select { |e| e.is_a? klass }
    end
  end
end
