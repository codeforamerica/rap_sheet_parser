module RapSheetParser
  class RapSheetBuilder
    def self.build(parsed_rap_sheet, logger:)
      event_nodes = parsed_rap_sheet.cycles.flat_map do |cycle|
        cycle.events.select do |event|
          if event.is_a? EventGrammar::Event
            true
          else
            logger.warn('Unrecognized event:')
            logger.warn(event.text_value)
          end
        end
      end

      events = event_nodes.map do |e|
        if conviction_event(e)
          ConvictionEventBuilder.new(e).build
        elsif e.is_a? EventGrammar::ArrestEvent
          ArrestEventBuilder.new(e).build
        elsif e.is_a? EventGrammar::CustodyEvent
          CustodyEventBuilder.new(e).build
        elsif e.is_a? EventGrammar::RegistrationEvent
          RegistrationEventBuilder.new(e).build
        end
      end.compact

      RapSheet.new(events)
    end

    private

    def self.conviction_event(e)
      e.is_a? EventGrammar::CourtEvent and e.is_conviction?
    end
  end
end

