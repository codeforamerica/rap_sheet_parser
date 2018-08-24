module RapSheetParser
  class RapSheetBuilder
    def initialize(parsed_rap_sheet, logger:)
      @parsed_rap_sheet = parsed_rap_sheet
      @logger = logger
    end

    def build
      RapSheet.new(cycles: cycles, personal_info: personal_info)
    end

    private

    def cycles
      @parsed_rap_sheet.cycles.map { |c| CycleBuilder.new(c, logger: @logger).build }
    end

    def personal_info
      PersonalInfoBuilder.new(@parsed_rap_sheet.personal_info).build
    end
  end
end
