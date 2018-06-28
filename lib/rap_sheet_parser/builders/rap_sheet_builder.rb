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

      personal_info = PersonalInfoBuilder.new(parsed_rap_sheet.personal_info).build

      events = event_nodes.map do |e|
        if conviction_event(e)
          ConvictionEventBuilder.new(e, logger: logger).build
        elsif e.is_a? EventGrammar::ArrestEvent
          ArrestEventBuilder.new(e, logger: logger).build
        elsif e.is_a? EventGrammar::CustodyEvent
          CustodyEventBuilder.new(e, logger: logger).build
        elsif e.is_a? EventGrammar::RegistrationEvent
          RegistrationEventBuilder.new(e, logger: logger).build
        end
      end.compact

      RapSheet.new(events: events, personal_info: personal_info)
    end

    private

    def self.conviction_event(e)
      e.is_a? EventGrammar::CourtEvent and e.is_conviction?
    end
  end
end

