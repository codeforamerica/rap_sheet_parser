module RapSheetParser
  module CountGrammar
    class Count < Treetop::Runtime::SyntaxNode
      def code_section
        if charge_line.is_a? CodeSectionLine
          charge_line.code_section
        elsif charge_line.is_a? SeeCommentForCharge
          disposition.code_section if disposition.is_a? DispositionGrammar::Disposition
        end
      end

      def code_section_description
        if charge_line.is_a? CodeSectionLine
          charge_line.code_section_description
        elsif charge_line.is_a? SeeCommentForCharge
          disposition.code_section_description if disposition.is_a? DispositionGrammar::Disposition
        end
      end

      def disposition
        disposition_content
      end
    end

    class Update < Treetop::Runtime::SyntaxNode
      def dispositions
        update_content.dispositions
      end

      def update_content
        return @update_content if @update_content

        @update_content = do_parsing(UpdateGrammarParser.new, text_value)
      end
    end

    class SeeCommentForCharge < Treetop::Runtime::SyntaxNode; end
    class CodeSectionLine < Treetop::Runtime::SyntaxNode; end
  end
end
