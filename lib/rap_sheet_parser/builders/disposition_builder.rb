module RapSheetParser
  class DispositionBuilder
    def initialize(disposition_node, logger:)
      @disposition_node = disposition_node
      @logger = logger
    end

    def build
      sentence = nil
      if @disposition_node.sentence
        sentence = ConvictionSentenceBuilder.new(@disposition_node.sentence).build
      end
      Disposition.new(type: @disposition_node.disposition_type.class.name.demodulize.underscore,
                      sentence: sentence,
                      text: @disposition_node.text_value.split("\n")[0]
      )
    end

    attr_reader :logger
  end
end
