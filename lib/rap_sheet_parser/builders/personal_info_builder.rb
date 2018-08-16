module RapSheetParser
  class PersonalInfoBuilder
    def initialize(personal_info_node)
      @personal_info_node = personal_info_node
    end

    def build
      return if personal_info_node.is_a? Unknown
      
      PersonalInfo.new(sex: sex, names: names, date_of_birth: date_of_birth, race: race)
    end

    private

    attr_reader :personal_info_node

    def sex
      personal_info_node.sex.text_value.slice(4)
    end

    def race
      personal_info_node.race.text_value.split('RAC/')[1].chomp
    end

    def names
      names = {}
      personal_info_node.names.map do |n|
        names[n.name_code.text_value] = n.name_value.text_value
      end
      names
    end

    def date_of_birth
      DateBuilder.new(personal_info_node.date_of_birth.date).build
    end
  end
end
