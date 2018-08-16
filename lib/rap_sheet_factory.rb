module RapSheetParser
  module RapSheetFactory
    def build_court_event(
      date: Date.new(1994, 1, 2),
      case_number: '12345',
      courthouse: 'CASC SAN FRANCISCO',
      counts: [build_court_count],
      updates: [],
      name_code: nil
    )

      RapSheetParser::CourtEvent.new(
        date: date,
        courthouse: courthouse,
        case_number: case_number,
        updates: updates,
        counts: counts,
        name_code: name_code
      )
    end
    
    def build_other_event(cycle_events: [], date: Date.today, counts: [], header:, agency: 'CAPD SAN FRANCISCO')
      OtherEvent.new(
        cycle_events: cycle_events,
        date: date,
        counts: counts,
        header: header,
        agency: agency
      )
    end

    def build_arrest_event(**params)
      build_other_event(params.merge(header: 'arrest'))
    end

    def build_rap_sheet(events: [], personal_info: nil)
      cycles = events.map {|e| Cycle.new(events:[e])}
      RapSheet.new(cycles: cycles, personal_info: personal_info)
    end

    def build_court_count(
      severity: 'M',
      code: 'PC',
      section: '123',
      code_section_description: 'foo',
      disposition_type: 'convicted',
      disposition_sentence: nil
    )
      RapSheetParser::CourtCount.new(
        code_section_description: code_section_description,
        severity: severity,
        code: code,
        section: section,
        disposition: Disposition.new(type: disposition_type, sentence: disposition_sentence)
      )
    end

    def build_personal_info(names: nil, sex: nil, date_of_birth: nil)
      RapSheetParser::PersonalInfo.new(names: names, sex: sex, date_of_birth: date_of_birth)
    end
  end
end
