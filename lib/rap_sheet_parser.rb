require 'treetop'
require 'logger'

require 'rap_sheet_parser/models/conviction_count'
require 'rap_sheet_parser/models/conviction_count_collection'
require 'rap_sheet_parser/models/arrest_event'
require 'rap_sheet_parser/models/registration_event'
require 'rap_sheet_parser/models/custody_event'
require 'rap_sheet_parser/models/conviction_event'
require 'rap_sheet_parser/models/rap_sheet'
require 'rap_sheet_parser/models/conviction_sentence'
require 'rap_sheet_parser/models/update'
require 'rap_sheet_parser/models/pc1203_dismissed_disposition'
require 'rap_sheet_parser/models/sentence_modified_disposition'
require 'rap_sheet_parser/models/okay_print'

require 'rap_sheet_parser/builders/case_number_builder'
require 'rap_sheet_parser/builders/conviction_count_builder'
require 'rap_sheet_parser/builders/event_builder'
require 'rap_sheet_parser/builders/conviction_event_builder'
require 'rap_sheet_parser/builders/arrest_event_builder'
require 'rap_sheet_parser/builders/registration_event_builder'
require 'rap_sheet_parser/builders/custody_event_builder'
require 'rap_sheet_parser/builders/courthouse_builder'
require 'rap_sheet_parser/builders/rap_sheet_builder'
require 'rap_sheet_parser/builders/conviction_sentence_builder'
require 'rap_sheet_parser/builders/update_builder'

require 'rap_sheet_parser/syntax_nodes/treetop_monkeypatches'
require 'rap_sheet_parser/syntax_nodes/cycle_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/rap_sheet_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/event_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/count_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/sentence_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/update_syntax_nodes'

require 'rap_sheet_parser/grammars/common_grammar'
require 'rap_sheet_parser/grammars/update_grammar'
require 'rap_sheet_parser/grammars/sentence_grammar'
require 'rap_sheet_parser/grammars/cycle_grammar'
require 'rap_sheet_parser/grammars/count_grammar'
require 'rap_sheet_parser/grammars/event_grammar'
require 'rap_sheet_parser/grammars/rap_sheet_grammar'

require 'rap_sheet_parser/text_cleaner'
require 'rap_sheet_parser/rap_sheet_parser_exception'
require 'rap_sheet_parser/version'

module RapSheetParser
  class Parser
    def parse(text, logger: Logger.new)
      cleaned_text = TextCleaner.clean(text)
      tree = do_parsing(RapSheetGrammarParser.new, cleaned_text)
      RapSheetBuilder.build(tree, logger: logger)
    end

    def do_parsing(parser, text)
      result = parser.parse(text)
      raise RapSheetParserException.new(parser, text) unless result

      result
    end
  end
end
