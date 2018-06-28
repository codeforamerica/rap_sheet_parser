module RapSheetParser
  module RapSheetGrammar
    class Cycle < Treetop::Runtime::SyntaxNode
      def events
        do_parsing(CycleGrammarParser.new, cycle_content.text_value).events
      end
    end

    class UnknownPersonalInfo < Treetop::Runtime::SyntaxNode; end
  end
end
