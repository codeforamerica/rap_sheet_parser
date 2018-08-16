module RapSheetParser
  class PersonalInfo
    def initialize(sex:, names:, date_of_birth:)
      @sex = sex
      @names = names
      @date_of_birth = date_of_birth
    end

    attr_reader :sex, :names, :date_of_birth
  end
end
