module RapSheetParser
  class RegistrationEventBuilder
    include EventBuilder

    def build
      event_syntax_node.updates.each do |update|
        logger.warn('Update on registration event:')
        logger.warn(update.text_value)
      end

      RegistrationEvent.new(
        date: date,
        code_section: code_section
      )
    end
    
    private

    def count
      CourtCountBuilder.new(event_syntax_node.counts[0], logger: logger).build
    end
    
    def code_section
      count.code_section
    end
  end
end
