module RapSheetParser
  class RapSheetParserException < StandardError
    def initialize(parser, text)
      @parser = parser
      @text = text
    end

    def message
      if ENV['VERBOSE_PARSER_EXCEPTIONS']
        "#{@parser.class} #{@parser.failure_reason}\n#{@text}"
      else
        'Parsing threw unexpected error'
      end
    end
  end
end
