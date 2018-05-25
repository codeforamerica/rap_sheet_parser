module RapSheetParser
  class CustodyEventBuilder
    include EventBuilder

    def build
      CustodyEvent.new(date: date)
    end
  end
end
