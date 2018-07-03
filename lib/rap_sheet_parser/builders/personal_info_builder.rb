module RapSheetParser
  class PersonalInfoBuilder
    def initialize(personal_info_node)
      @personal_info_node = personal_info_node
    end

    def build
      return if personal_info_node.is_a? Unknown
      
      personal_info = PersonalInfo.new(sex: sex, names: names)
      personal_info.save!
      personal_info
    end

    private

    attr_reader :personal_info_node

    def sex
      personal_info_node.sex.text_value.slice(4)
    end

    def names
      names = {}
      personal_info_node.names.map do |n|
        names[n.name_code.text_value] = n.name_value.text_value
      end
      names
    end
  end
end
