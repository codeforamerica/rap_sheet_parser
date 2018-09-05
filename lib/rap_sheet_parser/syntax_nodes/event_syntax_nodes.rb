module RapSheetParser
  module EventGrammar
    class Event < Treetop::Runtime::SyntaxNode
      def case_number
        counts[0].case_number if counts[0].is_a? CountWithCaseNumber
      end
    end

    class Count < Treetop::Runtime::SyntaxNode
      extend Forwardable

      def_delegators :count_content, :disposition, :code_section, :code_section_description, :updates, :flags

      def count_content
        return @count_content if @count_content

        @count_content = do_parsing(CountGrammarParser.new, count_info.text_value + "\n")
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
