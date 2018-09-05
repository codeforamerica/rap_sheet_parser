module RapSheetParser
  class ConvictionSentence
    def initialize(probation: nil, jail: nil, prison: nil, details: nil)
      @probation = probation
      @jail = jail
      @details = details
      @prison = prison
    end

    attr_reader :probation, :jail, :prison

    def total_duration
      (jail || 0.days) + (probation || 0.days) + (prison || 0.days)
    end

    def to_s
      [prison_string, probation_string, jail_string, *details].compact.join(', ')
    end

    private

    attr_reader :details

    def prison_string
      duration_string(prison, 'prison')
    end

    def probation_string
      duration_string(probation, 'probation')
    end

    def jail_string
      duration_string(jail, 'jail')
    end

    def duration_string(duration, type)
      return unless duration

      return type if duration.zero?

      key = duration.parts.keys[0]
      value = duration.parts[key]

      "#{value}#{key[0]} #{type}"
    end
  end
end
