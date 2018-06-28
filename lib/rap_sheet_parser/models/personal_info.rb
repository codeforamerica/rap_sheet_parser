module RapSheetParser
  class PersonalInfo
    def initialize(sex:)
      @sex = sex
    end

    attr_reader :sex
  end
end
