module RapSheetParser
  class UpdateBuilder
    def initialize(node, logger:)
      @node = node
      @logger = logger
    end

    def build
      Update.new(
        dispositions: dispositions
      )
    end

    private

    attr_reader :node

    def dispositions
      node.dispositions.map { |d| DispositionBuilder.new(d, date: DateBuilder.new(node.date).build, logger: @logger).build }
    end
  end
end
