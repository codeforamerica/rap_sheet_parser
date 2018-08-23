module RapSheetParser
  class DateBuilder
    def initialize(date_node)
      @date_node = date_node
    end

    def build
      Date.strptime(date_string, '%Y%m%d')
    rescue ArgumentError
      nil
    end

    private

    attr_reader :date_node

    def date_string
      date_node.text_value.delete('.')
    end
  end
end
