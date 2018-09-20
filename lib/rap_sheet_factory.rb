module RapSheetParser
  module RapSheetFactory
    def build_court_event(
      date: Date.new(1994, 1, 2),
      case_number: '12345',
      courthouse: 'SOME COURTHOUSE',
      counts: [build_count],
      name_code: nil
    )

      RapSheetParser::CourtEvent.new(
        date: date,
        courthouse: courthouse,
        case_number: case_number,
        counts: counts,
        name_code: name_code
      )
    end

    def build_other_event(cycle_events: [], date: Date.today, counts: [], event_type:, agency: 'SOME AGENCY')
      OtherEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: counts,
        event_type: event_type,
        agency: agency
      )
    end

    def build_arrest_event(params = {})
      build_other_event(params.merge(event_type: 'arrest'))
    end

    def build_rap_sheet(events: [], personal_info: nil)
      cycles = events.map { |e| Cycle.new(events: [e]) }
      RapSheet.new(cycles: cycles, personal_info: personal_info)
    end

    def build_count(
      code: 'PC',
      section: '123',
      code_section_description: 'foo',
      disposition: build_disposition,
      updates: [],
      flags: []
    )
      Count.new(
        code_section_description: code_section_description,
        code: code,
        section: section,
        disposition: disposition,
        updates: updates,
        flags: flags
      )
    end

    def build_disposition(type: 'convicted', sentence: nil, severity: 'M', text: '')
      Disposition.new(type: type, sentence: sentence, severity: severity, text: text)
    end

    def build_personal_info(names: nil, sex: nil, date_of_birth: nil, race: nil, cii: nil)
      RapSheetParser::PersonalInfo.new(
        cii: cii,
        names: names,
        sex: sex,
        date_of_birth: date_of_birth,
        race: race
      )
    end
  end
end
