module RapSheetParser
  class ConvictionEventPII
    def initialize(case_number:)
      @case_number = case_number
    end
    
    attr_reader :case_number
  end
end
