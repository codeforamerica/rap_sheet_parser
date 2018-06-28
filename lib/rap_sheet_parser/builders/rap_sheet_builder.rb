module RapSheetParser
  class RapSheetBuilder
    def initialize(parsed_rap_sheet, logger:)
      @parsed_rap_sheet = parsed_rap_sheet
      @logger = logger
    end

    def build
      RapSheet.new(events: events, personal_info: personal_info)
    end

    private

    def conviction_event(event)
      event.is_a? EventGrammar::CourtEvent and event.is_conviction?
    end

    def events
      event_nodes.map do |e|
        if conviction_event(e)
          ConvictionEventBuilder.new(e, logger: @logger).build
        elsif e.is_a? EventGrammar::ArrestEvent
          ArrestEventBuilder.new(e, logger: @logger).build
        elsif e.is_a? EventGrammar::CustodyEvent
          CustodyEventBuilder.new(e, logger: @logger).build
        elsif e.is_a? EventGrammar::RegistrationEvent
          RegistrationEventBuilder.new(e, logger: @logger).build
        end
      end.compact
    end

    def event_nodes
      @parsed_rap_sheet.cycles.flat_map do |cycle|
        cycle.events.select do |event|
          if event.is_a? EventGrammar::Event
            true
          else
            @logger.warn('Unrecognized event:')
            @logger.warn(event.text_value)
          end
        end
      end
    end

    def personal_info
      PersonalInfoBuilder.new(@parsed_rap_sheet.personal_info).build
    end
  end
end

