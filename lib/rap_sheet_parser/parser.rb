require 'treetop'
require 'logger'
require 'active_support/core_ext/module/delegation'

require 'rap_sheet_parser/models/court_count'
require 'rap_sheet_parser/models/other_event'
require 'rap_sheet_parser/models/court_event'
require 'rap_sheet_parser/models/rap_sheet'
require 'rap_sheet_parser/models/conviction_sentence'
require 'rap_sheet_parser/models/update'
require 'rap_sheet_parser/models/okay_print'
require 'rap_sheet_parser/models/disposition'
require 'rap_sheet_parser/models/personal_info'
require 'rap_sheet_parser/models/cycle'

require 'rap_sheet_parser/builders/date_builder'
require 'rap_sheet_parser/builders/case_number_builder'
require 'rap_sheet_parser/builders/court_count_builder'
require 'rap_sheet_parser/builders/event_builder'
require 'rap_sheet_parser/builders/court_event_builder'
require 'rap_sheet_parser/builders/other_event_builder'
require 'rap_sheet_parser/builders/registration_event_builder'
require 'rap_sheet_parser/builders/courthouse_builder'
require 'rap_sheet_parser/builders/rap_sheet_builder'
require 'rap_sheet_parser/builders/cycle_builder'
require 'rap_sheet_parser/builders/conviction_sentence_builder'
require 'rap_sheet_parser/builders/update_builder'
require 'rap_sheet_parser/builders/disposition_builder'
require 'rap_sheet_parser/builders/personal_info_builder'

require 'rap_sheet_parser/syntax_nodes/treetop_monkeypatches'
require 'rap_sheet_parser/syntax_nodes/cycle_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/rap_sheet_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/event_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/disposition_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/count_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/sentence_syntax_nodes'
require 'rap_sheet_parser/syntax_nodes/update_syntax_nodes'

require 'rap_sheet_parser/grammars/common_grammar'
require 'rap_sheet_parser/grammars/disposition_grammar'
require 'rap_sheet_parser/grammars/update_grammar'
require 'rap_sheet_parser/grammars/sentence_grammar'
require 'rap_sheet_parser/grammars/cycle_grammar'
require 'rap_sheet_parser/grammars/count_grammar'
require 'rap_sheet_parser/grammars/event_grammar'
require 'rap_sheet_parser/grammars/registration_cycle_event_grammar'
require 'rap_sheet_parser/grammars/other_cycle_event_grammar'
require 'rap_sheet_parser/grammars/rap_sheet_grammar'

require 'rap_sheet_parser/text_cleaner'
require 'rap_sheet_parser/rap_sheet_parser_exception'

module RapSheetParser
  class Parser
    def parse(text, logger: Logger.new('/dev/null'))
      cleaned_text = TextCleaner.clean(text)
      parser = RapSheetGrammarParser.new

      result = parser.parse(cleaned_text)
      raise RapSheetParserException.new(parser, cleaned_text) unless result

      RapSheetBuilder.new(result, logger: logger).build
    end
  end
end
