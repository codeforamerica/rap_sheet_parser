module RapSheetParser
  class CourtEventBuilder
    include EventBuilder

    def build
      CourtEvent.new(
        cycle_events: cycle_events,
        name_code: name_code,
        date: date,
        pii: pii,
        courthouse: courthouse,
        sentence: sentence,
        updates: updates,
        counts: counts
      )
    end

    private

    def name_code
      return if event_syntax_node.name.is_a? Unknown

      event_syntax_node.name.name_code.text_value
    end

    def pii
      ConvictionEventPII.new(
        case_number: CaseNumberBuilder.new(event_syntax_node.case_number).build
      )
    end

    def courthouse
      CourthouseBuilder.new(event_syntax_node.courthouse, logger: logger).build
    end

    def sentence
      if event_syntax_node.sentence
        sentence_modified_disposition = updates.flat_map(&:dispositions).find do |d|
          d.is_a?(SentenceModifiedDisposition)
        end

        if sentence_modified_disposition
          sentence_modified_disposition.sentence
        else
          ConvictionSentenceBuilder.new(event_syntax_node.sentence).build
        end
      end
    end

    def updates
      event_syntax_node.updates.map { |u| UpdateBuilder.new(u).build }
    end
  end
end
