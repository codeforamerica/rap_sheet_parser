module RapSheetParser
  class RegistrationEventBuilder < OtherEventBuilder
    def build
      event_syntax_node.counts.each do |count|
        count.updates.each do |update|
          logger.warn('Update on registration event:')
          logger.warn(update.text_value)
        end
      end

      super
    end
  end
end
