module RapSheetParser
  class RegistrationEvent
    def initialize(date:, code_section:)
      @date = date
      @code_section = code_section
    end

    attr_reader :date, :code_section
  end
end
