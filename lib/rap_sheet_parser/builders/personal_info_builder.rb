module RapSheetParser
  class PersonalInfoBuilder
    def initialize(personal_info_node)
      @personal_info_node = personal_info_node
    end

    def build
      if personal_info_node.is_a? RapSheetGrammar::UnknownPersonalInfo
        return PersonalInfo.new(sex: nil)
      end

      PersonalInfo.new(sex: sex)
    end

    private

    attr_reader :personal_info_node

    def sex
      personal_info_node.sex.text_value.slice(4)
    end
  end
end
