module RapSheetParser
  module RapSheetFactory
    def build_conviction_event(
      date: Date.new(1994, 1, 2),
      case_number: '12345',
      courthouse: 'CASC SAN FRANCISCO',
      sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
      counts: [build_court_count],
      updates: [],
      name_code: nil
    )

      RapSheetParser::ConvictionEvent.new(
        date: date,
        courthouse: courthouse,
        pii: ConvictionEventPII.new(case_number: case_number),
        sentence: sentence,
        updates: updates,
        counts: counts,
        name_code: name_code
      )
    end

    def build_arrest_event(cycle_events: [], date: Date.today, counts: [])
      ArrestEvent.new(cycle_events: cycle_events, date: date, counts: counts)
    end

    def build_rap_sheet(events: [], personal_info: nil)
      RapSheet.new(events: events, personal_info: personal_info)
    end

    def build_court_count(
      severity: 'M',
      code: 'PC',
      section: '123',
      code_section_description: 'foo',
      disposition: 'convicted'
    )
      RapSheetParser::CourtCount.new(
        code_section_description: code_section_description,
        severity: severity,
        code: code,
        section: section,
        disposition: disposition
      )
    end

    def build_personal_info(names: nil, sex: nil)
      RapSheetParser::PersonalInfo.new(names: names, sex: sex)
    end
  end
end
