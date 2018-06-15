module RapSheetParser
  class SentenceModifiedDisposition
    def initialize(sentence:)
      @sentence = sentence
    end
    
    attr_reader :sentence
  end
end
