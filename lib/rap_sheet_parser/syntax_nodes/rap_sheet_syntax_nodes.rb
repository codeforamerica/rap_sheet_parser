module RapSheetParser
  module RapSheetGrammar
    class Cycle < Treetop::Runtime::SyntaxNode
      def events
        cycle_content.events
      end
    end

    class PersonalInfo < Treetop::Runtime::SyntaxNode
      def names
        recursive_select(Name)
      end
    end

    class Name < Treetop::Runtime::SyntaxNode; end

    class RapDate < Treetop::Runtime::SyntaxNode; end

    class CycleContent < Treetop::Runtime::SyntaxNode
      def events
        do_parsing(CycleGrammarParser.new, text_value).recursive_select(CycleGrammar::EventContent).map do |event|
          do_parsing(event_parser_class.new, event.text_value)
        end
      end
    end

    class OtherCycleContent < CycleContent
      def event_parser_class
        OtherCycleEventGrammarParser
      end
    end

    class RegistrationCycleContent < CycleContent
      def event_parser_class
        RegistrationCycleEventGrammarParser
      end
    end
  end
end
