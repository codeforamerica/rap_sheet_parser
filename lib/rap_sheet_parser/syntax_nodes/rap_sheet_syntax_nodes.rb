module RapSheetParser
  module RapSheetGrammar
    class Cycle < Treetop::Runtime::SyntaxNode
      def events
        do_parsing(CycleGrammarParser.new, cycle_content.text_value).events
      end
    end

    class PersonalInfo < Treetop::Runtime::SyntaxNode
      def names
        recursive_select(Name)
      end
    end

    class Name < Treetop::Runtime::SyntaxNode; end

    class UnknownPersonalInfo < Treetop::Runtime::SyntaxNode; end
  end
end
