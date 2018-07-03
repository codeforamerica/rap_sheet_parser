module RapSheetParser
  class PersonalInfoBuilder
    def initialize(personal_info_node)
      @personal_info_node = personal_info_node
    end

    def build
      return if personal_info_node.is_a? RapSheetGrammar::UnknownPersonalInfo
      
      personal_info = PersonalInfo.new(sex: sex)
      personal_info.save!
      personal_info
    end

    private

    attr_reader :personal_info_node

    def sex
      personal_info_node.sex.text_value.slice(4)
    end
  end
end
