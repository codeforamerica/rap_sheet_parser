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

    class CycleContent < Treetop::Runtime::SyntaxNode
      def parsed_cycle
        do_parsing(CycleGrammarParser.new, text_value)
      end
    end

    class OtherCycleContent < CycleContent
      def events
        parsed_cycle.recursive_select(CycleGrammar::EventContent).map do |event|
          do_parsing(OtherCycleEventGrammarParser.new, event.text_value)
        end
      end
    end

    class RegistrationCycleContent < CycleContent
      def events
        parsed_cycle.recursive_select(CycleGrammar::EventContent).each_with_index.map do |event, index|
          do_parsing(
            RegistrationCycleEventGrammarParser.new,
            index == 0 ? event.text_value : "REGISTRATION:\n#{event.text_value}"
          )
        end
      end
    end
  end
end
