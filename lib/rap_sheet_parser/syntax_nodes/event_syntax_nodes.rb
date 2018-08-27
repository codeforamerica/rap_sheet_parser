module RapSheetParser
  module EventGrammar
    class Event < Treetop::Runtime::SyntaxNode
      def case_number
        counts[0].case_number if counts[0].is_a? CountWithCaseNumber
      end
    end

    class Count < Treetop::Runtime::SyntaxNode
      def disposition
        count_content.disposition
      end

      def code_section
        count_content.code_section
      end

      def code_section_description
        count_content.code_section_description
      end

      def count_content
        return @count_content if @count_content

        @count_content = do_parsing(CountGrammarParser.new, count_info.text_value + "\n")
      end
    end

    class Update < Treetop::Runtime::SyntaxNode
      def dispositions
        update_content.dispositions.elements
      end

      def update_content
        return @update_content if @update_content

        @update_content = do_parsing(UpdateGrammarParser.new, update_info.text_value + "\n")
      end
    end

    class CountWithCaseNumber < Count; end

    class EventIdentifier < Treetop::Runtime::SyntaxNode; end
    class RegistrationEventIdentifier < EventIdentifier; end
    class CourtEventIdentifier < EventIdentifier; end
    class ProbationEventIdentifier < EventIdentifier; end
    class ArrestEventIdentifier < EventIdentifier; end
    class SupplementalArrestEventIdentifier < EventIdentifier; end
    class MentalHealthEventIdentifier < EventIdentifier; end
    class CustodyEventIdentifier < EventIdentifier; end
    class ApplicantEventIdentifier < EventIdentifier; end
    class DeceasedEventIdentifier < EventIdentifier; end
  end
end
