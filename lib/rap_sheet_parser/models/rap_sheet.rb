module RapSheetParser
  class RapSheet
    attr_reader :cycles, :personal_info

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

    def arrests
      filtered_events(ArrestEvent)
    end

    def custody_events
      filtered_events(OtherEvent).select do |event|
        event.header == 'custody'
      end
    end

    def applicant_events
      other_events('applicant')
    end

    def probation_events
      other_events('probation')
    end

    def registration_events
      filtered_events(RegistrationEvent)
    end

    def superstrikes
      @superstrikes ||= convictions.
        flat_map(&:convicted_counts).
        select(&:superstrike?)
    end

    def sex_offender_registration?
      registration_event_with_code('PC 290')
    end

    def narcotics_offender_registration?
      registration_event_with_code('HS 11590')
    end

    private

    def registration_event_with_code(code)
      registration_events.
        map(&:code_section).
        any? { |code_section| code_section.start_with?(code) }
    end

    def filtered_events(klass)
      events.select { |e| e.is_a? klass }
    end

    def other_events(header)
      filtered_events(OtherEvent).select { |event| event.header == header }
    end
  end
end
