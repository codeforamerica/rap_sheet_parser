module RapSheetParser
  class PersonalInfo < ApplicationRecord
    def initialize(sex:, names:)
      super(sex: sex)

      @names = names
    end

    attr_reader :names
  end
end
