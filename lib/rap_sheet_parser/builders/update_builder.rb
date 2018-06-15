module RapSheetParser
  class UpdateBuilder
    def initialize(node)
      @node = node
    end
    
    def build
      Update.new(
        dispositions: dispositions
      )
    end

    private

    attr_reader :node
    
    def dispositions
      node.dispositions.map do |d|
        if d.disposition_type.is_a?(UpdateGrammar::PC1203Dismissed)
          PC1203DismissedDisposition.new
        elsif d.disposition_type.is_a?(UpdateGrammar::SentenceModified)
          SentenceModifiedDisposition.new(sentence: ConvictionSentenceBuilder.build(d.sentence))
        end
      end
    end
  end
end
