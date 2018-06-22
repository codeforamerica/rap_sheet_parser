module RapSheetParser
  class ConvictionEventBuilder
    include EventBuilder

    def build
      conviction_event = ConvictionEvent.new(
        date: date,
        case_number: case_number,
        courthouse: courthouse,
        sentence: sentence,
        updates: updates
      )

      conviction_event.counts = event_syntax_node.conviction_counts.map do |count|
        num_counts(count).times.map do |_|
          ConvictionCountBuilder.new(conviction_event, count).build
        end
      end.flatten

      conviction_event
    end

    private

    def num_counts(count)
      if count.count_identifier.end_number.text_value.present?
        1 + count.count_identifier.end_number.text_value.to_i - count.count_identifier.start_number.text_value.to_i
      else
        1
      end
    end

    def case_number
      CaseNumberBuilder.build(event_syntax_node.case_number)
    end

    def courthouse
      CourthouseBuilder.build(event_syntax_node.courthouse, logger: logger)
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
