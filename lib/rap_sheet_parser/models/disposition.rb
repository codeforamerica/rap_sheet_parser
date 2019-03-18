module RapSheetParser
  class Disposition
    attr_reader :sentence, :type, :text, :severity

    def initialize(type:, sentence:, severity:, text:, count:)
      @type = type
      @sentence = sentence
      @severity = severity
      @text = text
      @count = count
    end

    def sentences
      seen_sentences = []
      seen_sentences << sentence
      if @count.updates[0].dispositions
        new_sentence = @count.updates[0].dispositions[0].sentence
        new_sentence = ConvictionSentenceBuilder.new(new_sentence).build
        seen_sentences << new_sentence
      end
      seen_sentences
    end

    def original_sentence
      sentences[0]
    end

    def most_recent_sentence
      sentences[-1]
    end
  end
end
