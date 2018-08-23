module RapSheetParser
  module CountGrammar
    class Count < Treetop::Runtime::SyntaxNode
      def code_section
        if charge_line.is_a? CodeSectionLine
          charge_line.code_section
        elsif charge_line.is_a? SeeCommentForCharge
          if disposition.is_a? DispositionGrammar::Disposition
            comment_charge_line = disposition.comment_charge_line
            comment_charge_line.code_section unless comment_charge_line.empty?
          end
        end
      end

      def code_section_description
        if charge_line.is_a? CodeSectionLine
          charge_line.code_section_description
        end
      end

      def disposition
        disposition_content
      end
    end

    class SeeCommentForCharge < Treetop::Runtime::SyntaxNode; end
    class CodeSectionLine < Treetop::Runtime::SyntaxNode; end
  end
end
