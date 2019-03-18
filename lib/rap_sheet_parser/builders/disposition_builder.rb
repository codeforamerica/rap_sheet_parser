module RapSheetParser
  class DispositionBuilder
    def initialize(disposition_node, logger:, count:)
      @disposition_node = disposition_node
      @logger = logger
      @count = count
    end

    def build
      Disposition.new(
        type: @disposition_node.disposition_type.class.name.demodulize.underscore,
        sentence: sentence,
        severity: severity,
        text: @disposition_node.text_value.split("\n")[0],
        count: @count
      )
    end

    private

    attr_reader :logger

    def severity
      return unless @disposition_node.severity

      @disposition_node.severity.text_value[0]
    end

    def sentence
      return unless @disposition_node.sentence

      ConvictionSentenceBuilder.new(@disposition_node.sentence).build
    end
  end
end
