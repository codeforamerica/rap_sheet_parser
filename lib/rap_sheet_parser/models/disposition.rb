module RapSheetParser
  class Disposition

    def initialize(type:, sentence:)
      @type = type
      @sentence = sentence
    end

    attr_reader :sentence, :type
  end
end