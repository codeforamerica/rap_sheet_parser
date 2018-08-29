module RapSheetParser
  class CourtEventBuilder
    include EventBuilder

    def build
      CourtEvent.new(
        cycle_events: cycle_events,
        name_code: name_code,
        date: date,
        case_number: case_number,
        courthouse: courthouse,
        counts: counts
      )
    end

    private

    def name_code
      return if event_syntax_node.name.is_a? Unknown

      event_syntax_node.name.name_code.text_value
    end

    def case_number
      CaseNumberBuilder.new(event_syntax_node.case_number).build
    end

    def courthouse
      CourthouseBuilder.new(event_syntax_node.courthouse, logger: logger).build
    end
  end
end
