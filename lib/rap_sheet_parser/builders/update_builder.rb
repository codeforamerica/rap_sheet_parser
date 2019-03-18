module RapSheetParser
  class UpdateBuilder
    def initialize(node, logger:, count:)
      @node = node
      @logger = logger
      @count = count
    end

    def build
      Update.new(
        dispositions: dispositions
      )
    end

    private

    attr_reader :node

    def dispositions
      node.dispositions.map { |d| DispositionBuilder.new(d, count: @count, logger: @logger).build }
    end
  end
end
