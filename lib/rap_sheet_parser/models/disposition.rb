module RapSheetParser
  class Disposition

    def initialize(type:, sentence:, text:)
      @type = type
      @sentence = sentence
      @text = text
    end

    attr_reader :sentence, :type, :text
  end
end
