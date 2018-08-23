module RapSheetParser
  class Disposition
    attr_reader :sentence, :type, :text, :severity

    def initialize(type:, sentence:, severity:, text:)
      @type = type
      @sentence = sentence
      @severity = severity
      @text = text
    end
  end
end
