require_relative './treetop_monkeypatches'

module RapSheetParser
  module UpdateGrammar
    class Update < Treetop::Runtime::SyntaxNode; end
  end
end
