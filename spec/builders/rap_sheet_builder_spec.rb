require 'spec_helper'

module RapSheetParser
  RSpec.describe RapSheetBuilder do
    describe '.build' do
      it 'returns a rap sheet object from a treetop node' do
        text = <<~TEXT
          blah blah
          CII/A12345678
          DOB/19911010    SEX/M   RAC/WOOKIE
          NAM/01 BACCA, CHEW
              02 BACCA, CHEW E.
              03 WOOKIE, CHEWBACCA
          * * * *
          REGISTRATION:         NAM:01
          20171216 CASO SAN DIEGO

          CNT:01
            290 PC-REGISTRATION OF SEX OFFENDER
          * * * *
          REGISTRATION:         NAM:01
          19901022  CAPD SAN FRANCISCO

          CNT:01     #44345345
           11590 HS-REGISTRATION OF CNTL SUB OFFENDER
          * * * *
          ARR/DET/CITE:
          NAM:001
          19910105 CAPD CONCORD
          TOC:F
          CNT:001
          #65131
          496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          - - - -
          SUPPLEMENTAL ARR:      NAM:01
          20110124  CASO SAN FRANCISCO

          CNT:01     #024435345
            32 PC-ACCESSORY
          - - - -
          COURT:
          19740102 CASC SAN FRANCISCO

          CNT: 001 #123
          DISPO:DISMISSED/FURTHERANCE OF JUSTICE
          * * * *
          COURT: NAME7OZ
          19820915 CAMC LOS ANGELES METRO

          CNT: 001 #456
          bla bla
          DISPO:CONVICTED

          CNT:002
          bla bla
          DISPO:DISMISSED

          CNT:003
          4056 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
          * * * *
          COURT:
          NAM: 003
          19941120 CAMC HAYWARD

          CNT: 001 #612
          487.2 PC-GRAND THEFT FROM PERSON
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          * * * *
          CUSTODY:JAIL
          NAM:001
          20120503 CASO MARTINEZ
          CNT:001 #Cc12EA868A-070KLK602
          459 PC-BURGLARY
          TOC:F
          * * * *
          APPLICANT:            NAM:04
          20051221  CASC SACRAMENTO
          CNT:01     #ABCBA
            APPLICANT ADULT DAY/RESIDENT REHAB
          * * * *
          PROBATION:            NAM:04
          20051221  CASC SACRAMENTO
          CNT:01     #ABCBA
            APPLICANT ADULT DAY/RESIDENT REHAB
          * * * END OF MESSAGE * * *
        TEXT

        warnings = StringIO.new
        rap_sheet = RapSheetParser::Parser.new.parse(text, logger: Logger.new(warnings))

        expect(rap_sheet.arrest_events[0].date).to eq Date.new(1991, 1, 5)
        expect(rap_sheet.personal_info.sex).to eq 'M'
        expect(rap_sheet.personal_info.date_of_birth).to eq Date.new(1991, 10, 10)
        expect(rap_sheet.personal_info.names['01']).to eq 'BACCA, CHEW'
        expect(rap_sheet.personal_info.names['02']).to eq 'BACCA, CHEW E.'
        expect(rap_sheet.personal_info.names['03']).to eq 'WOOKIE, CHEWBACCA'
        expect(rap_sheet.personal_info.race).to eq 'WOOKIE'
        expect(rap_sheet.personal_info.cii).to eq 'A12345678'

        verify_event_looks_like(
          rap_sheet.convictions[0],
          name_code: nil,
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC Los Angeles Metro',
          sentence: ''
        )
        verify_event_looks_like(
          rap_sheet.convictions[1],
          name_code: '003',
          date: Date.new(1994, 11, 20),
          case_number: '612',
          courthouse: 'CAMC Hayward',
          sentence: '12m probation, 45d jail'
        )

        expect(rap_sheet.custody_events[0].date).to eq Date.new(2012, 5, 3)

        verify_count_looks_like(
          rap_sheet.convictions[0].counts[0],
          code_section: nil,
          code_section_description: nil,
          severity: nil,
          convicted: true,
          sentence: ''
        )
        verify_count_looks_like(
          rap_sheet.convictions[0].counts[1],
          code_section: nil,
          code_section_description: nil,
          severity: nil,
          convicted: false,
          sentence: ''
        )
        verify_count_looks_like(
          rap_sheet.convictions[0].counts[2],
          code_section: 'PC 4056',
          code_section_description: 'BREAKING AND ENTERING',
          severity: nil,
          convicted: true,
          sentence: ''
        )
        verify_count_looks_like(
          rap_sheet.convictions[1].counts[0],
          code_section: 'PC 487.2',
          code_section_description: 'GRAND THEFT FROM PERSON',
          severity: 'M',
          convicted: true,
          sentence: '12m probation, 45d jail'
        )

        expect(rap_sheet.registration_events[0].date).to eq Date.new(2017, 12, 16)
        expect(rap_sheet.registration_events[0].counts[0].code_section).to eq 'PC 290'
        expect(rap_sheet.registration_events[1].date).to eq Date.new(1990, 10, 22)
        expect(rap_sheet.registration_events[1].counts[0].code_section).to eq 'HS 11590'

        expect(rap_sheet.applicant_events.length).to eq 1
        expect(rap_sheet.probation_events.length).to eq 1
        expect(rap_sheet.convictions.length).to eq 2
        expect(rap_sheet.convictions[0].counts.length).to eq 3
        expect(rap_sheet.convictions[0].convicted_counts.length).to eq 2

        expect(warnings.string).to be_empty
      end

      it 'populates cycle events for each event' do
        text = <<~TEXT
          blah blah
          * * * *
          ARR/DET/CITE:
          NAM:001
          19910105 CAPD CONCORD
          TOC:F
          CNT:001
          #65131
          496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          - - - -
          COURT:
          19740102 CASC SAN PRANCISCU rm

          CNT: 001 #123
          DISPO:DISMISSED/FURTHERANCE OF JUSTICE
          - - - -
          COURT: NAME7OZ
          19820915 CAMC LOS ANGELES METRO

          CNT: 001 #456
          4056 PC-BREAKING AND ENTERING
          *DISPO:CONVICTED
          MORE INFO ABOUT THIS COUNT
          * * * END OF MESSAGE * * *
        TEXT

        rap_sheet = RapSheetParser::Parser.new.parse(text)

        expect(rap_sheet.events.length).to eq 3
        expect(rap_sheet.arrest_events[0].cycle_events.length).to eq 3
      end

      it 'logs warnings for unrecognized events' do
        text = <<~TEXT
          info
          * * * *
          UNKNOWN EVENT???
          * * * END OF MESSAGE * * *
        TEXT

        log = StringIO.new
        logger = Logger.new(log)
        RapSheetParser::Parser.new.parse(text, logger: logger)
        expect(log.string).to include 'WARN -- : Unrecognized event:'
        expect(log.string).to include 'WARN -- : UNKNOWN EVENT???'
      end

      it 'can parse a rap sheet with page breaks' do
        text = <<~TEXT
          blah blah
          * * * *
          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001  #346477
                    Page 2 of 29
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL

          CNT:002
          Page 13 of 16
            11357 HS-POSSESS
          TOC:M
          *DISPO:CONVICTED
          CONV STATUS:FELONY
          SEN: 002 YEARS PROBATION, 045 DAYS JAIL, FINE, IMP SEN SS
          * * * END OF MESSAGE * * *
        TEXT

        rap_sheet = RapSheetParser::Parser.new.parse(text)
        event = rap_sheet.events[0]

        expect(event).to be_a(RapSheetParser::CourtEvent)
        expect(event.counts.length).to eq 2
        expect(event.convicted_counts.length).to eq 2
        expect(event.convicted_counts[0].code).to eq 'PC'
        expect(event.convicted_counts[0].section).to eq '496'
        expect(event.convicted_counts[0].code_section).to eq 'PC 496'

        expect(event.convicted_counts[1].code).to eq 'HS'
        expect(event.convicted_counts[1].section).to eq '11357'
        expect(event.convicted_counts[1].code_section).to eq 'HS 11357'
      end

      it 'parses unusual characters in the TOC' do
        text = <<~TEXT
          info
          * * * *

          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001  #346477
          TÓC:M
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          * * * END OF MESSAGE * * *
        TEXT

        rap_sheet = RapSheetParser::Parser.new.parse(text)
        count = rap_sheet.events[0].counts[0]

        expect(count.code).to eq 'PC'
        expect(count.section).to eq '496'
        expect(count.code_section).to eq 'PC 496'
        expect(count.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      end

      it 'parses when TOC shows up directly above code section line' do
        text = <<~TEXT
          info
          * * * *

          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001  #346477
          TOC:M
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          * * * END OF MESSAGE * * *
        TEXT

        rap_sheet = RapSheetParser::Parser.new.parse(text)
        count = rap_sheet.events[0].counts[0]

        expect(count.code).to eq 'PC'
        expect(count.section).to eq '496'
        expect(count.code_section).to eq 'PC 496'
        expect(count.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      end
    end
  end
end
