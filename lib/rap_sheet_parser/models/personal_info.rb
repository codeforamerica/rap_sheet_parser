module RapSheetParser
  class PersonalInfo
    def initialize(sex:, names:, date_of_birth:, race:)
      @sex = sex
      @names = names
      @date_of_birth = date_of_birth
      @race = race
    end

    attr_reader :sex, :names, :date_of_birth, :race
  end
end
