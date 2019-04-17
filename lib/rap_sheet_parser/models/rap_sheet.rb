module RapSheetParser
  class RapSheet
    attr_reader :cycles, :personal_info

    EVENT_TYPES = %w[
      arrest
      custody
      applicant
      probation
      registration
      supplemental_arrest
      deceased
      mental_health
    ].freeze

    EVENT_TYPES.each do |type|
      define_method("#{type}_events") do
        filtered_events(OtherEvent).select { |event| event.event_type == type }
      end
    end

    def initialize(cycles:, personal_info:)
      @cycles = cycles
      @personal_info = personal_info
    end

    def events
      cycles.flat_map(&:events)
    end

    def convictions
      filtered_events(CourtEvent).select(&:convicted?)
    end

    def superstrikes
      @superstrikes ||= convictions.flat_map(&:convicted_counts)
                                   .select(&:superstrike?)
    end

    def sex_offender_registration?
      registration_event_with_code('PC 290')
    end

    def narcotics_offender_registration?
      registration_event_with_code('HS 11590')
    end

    def currently_serving_sentence?
      convictions.any?(&:currently_serving_sentence?)
    end

    private

    def registration_event_with_code(code)
      registration_events
        .flat_map(&:counts)
        .any? { |count| count.subsection_of?([code]) }
    end

    def filtered_events(klass)
      events.select { |e| e.is_a? klass }
    end
  end
end
