module RapSheetParser
  module DispositionGrammar
    class Disposition < Treetop::Runtime::SyntaxNode
      def severity
        disposition_info.find { |l| l.is_a? SeverityLine }&.severity
      end

      def sentence
        @sentence ||= begin
          if sentence_line
            sentence_text = TextCleaner.clean_sentence(sentence_line.sentence.text_value)
            do_parsing(SentenceGrammarParser.new, sentence_text)
          end
        end
      end

      def code_section
        comment_charge_line&.code_section
      end

      private

      def comment_charge_line
        disposition_info.find do |l|
          l.is_a? DispositionGrammar::CommentChargeLine
        end
      end

      def sentence_line
        disposition_info.find do |l|
          l.is_a?(SentenceLine) || l.is_a?(CommentSentenceLine)
        end
      end
    end

    class Convicted < Treetop::Runtime::SyntaxNode; end
    class Dismissed < Treetop::Runtime::SyntaxNode; end
    class OtherDispositionType < Treetop::Runtime::SyntaxNode; end
    class ProsecutorRejected < Treetop::Runtime::SyntaxNode; end
    class SentenceModified < Treetop::Runtime::SyntaxNode; end
    class PC1203Dismissed < Treetop::Runtime::SyntaxNode; end

    class SeverityLine < Treetop::Runtime::SyntaxNode; end
    class SentenceLine < Treetop::Runtime::SyntaxNode; end
    class CommentSentenceLine < Treetop::Runtime::SyntaxNode; end
    class CommentChargeLine < Treetop::Runtime::SyntaxNode; end
  end
end
