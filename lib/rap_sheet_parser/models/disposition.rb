module RapSheetParser
  class Disposition
    attr_reader :sentence, :type, :text, :severity, :date

    def initialize(type:, sentence:, severity:, text:, date:)
      @type = type
      @sentence = sentence
      @severity = severity
      @text = text
      @date = date
    end
  end
end
