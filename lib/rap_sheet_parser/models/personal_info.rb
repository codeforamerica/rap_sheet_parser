module RapSheetParser
  class PersonalInfo
    def initialize(sex:, names:, date_of_birth:, race:, cii:)
      @sex = sex
      @names = names
      @date_of_birth = date_of_birth
      @race = race
      @cii = cii
    end

    attr_reader :sex, :names, :date_of_birth, :race, :cii
  end
end
