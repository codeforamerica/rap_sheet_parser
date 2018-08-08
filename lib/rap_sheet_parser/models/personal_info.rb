module RapSheetParser
  class PersonalInfo
    def initialize(sex:, names:)
      @sex = sex
      @names = names
    end

    attr_reader :sex, :names
  end
end
