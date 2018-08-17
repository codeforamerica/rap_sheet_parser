module RapSheetParser
  class PersonalInfoBuilder
    def initialize(personal_info_node)
      @personal_info_node = personal_info_node
    end

    def build
      return if personal_info_node.is_a? Unknown
      
      PersonalInfo.new(
        cii: cii,
        sex: sex,
        names: names,
        date_of_birth: date_of_birth,
        race: race
      )
    end

    private

    attr_reader :personal_info_node

    def sex
      if(personal_info_node.sex.respond_to? :sex_value)
        personal_info_node.sex.sex_value.text_value
      end
    end

    def cii
      if(personal_info_node.cii.respond_to? :cii_value)
        personal_info_node.cii.cii_value.text_value
      end
    end

    def race
      if(personal_info_node.race.respond_to? :race_value)
        personal_info_node.race.race_value.text_value.chomp('')
      end
    end

    def names
      names = {}
      personal_info_node.names.map do |n|
        names[n.name_code.text_value] = n.name_value.text_value
      end
      names
    end

    def date_of_birth
      if(personal_info_node.date_of_birth.respond_to? :date)
        DateBuilder.new(personal_info_node.date_of_birth.date).build
      end
    end
  end
end
