module RapSheetParser
  class ConvictionEventBuilder
    include EventBuilder

    def build
      conviction_event = ConvictionEvent.new(
        date: date,
        case_number: case_number,
        courthouse: courthouse,
        sentence: sentence,
        dismissed_by_pc1203: event_syntax_node.dismissed_by_pc1203?
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
      CourthousePresenter.present(event_syntax_node.courthouse)
    end

    def sentence
      if event_syntax_node.sentence
        ConvictionSentenceBuilder.new(event_syntax_node.sentence).build
      end
    end
  end
end
