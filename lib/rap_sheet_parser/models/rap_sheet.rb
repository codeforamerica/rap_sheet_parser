module RapSheetParser
  class RapSheet
    attr_reader :cycles, :personal_info

    %w(arrest custody applicant probation registration supplemental_arrest deceased).each do |type|
      define_method("#{type}_events") do
        filtered_events(OtherEvent).select { |event| event.header == type }
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
      filtered_events(CourtEvent).select(&:conviction?)
    end

    def superstrikes
      @superstrikes ||= convictions
        .flat_map(&:convicted_counts)
        .select(&:superstrike?)
    end

    def sex_offender_registration?
      registration_event_with_code('PC 290')
    end

    def narcotics_offender_registration?
      registration_event_with_code('HS 11590')
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
