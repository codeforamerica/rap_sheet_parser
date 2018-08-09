require 'spec_helper'

module RapSheetParser
  RSpec.describe OtherCycleEventGrammarParser do
    describe '#parse' do
      context 'parsing a court event' do
        it 'parses' do
          text = <<~TEXT
            COURT:
            NAM:02
            20040102  CASC SAN FRANCISCO

            CNT: 001  #346477
              496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
            *DISPO:CONVICTED
            CONV STATUS:MISDEMEANOR
            SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
            COM: SENTENCE CONCURRENT WITH FILE #743-2:

            CNT: 002
            count 2 text
            DISPO:DISMISSED

            CNT: 003
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.event_identifier).to be_a(EventGrammar::CourtEventIdentifier)

          expect(tree.name.name_code.text_value).to eq ('02')

          expect(tree.date.text_value).to eq('20040102')

          expect(tree.courthouse.text_value).to eq('CASC SAN FRANCISCO')

          expect(tree.case_number.text_value).to eq('#346477')

          count_1 = tree.counts[0]
          expect(count_1.disposition.disposition_type).to be_a CountGrammar::Convicted
          expect(count_1.code_section.code.text_value).to eq 'PC'
          expect(count_1.code_section.number.text_value).to eq '496'
          expect(count_1.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

          count_2 = tree.counts[1]
          expect(count_2.disposition.disposition_type).to be_a CountGrammar::Dismissed
          count_3 = tree.counts[2]
          expect(count_3.disposition.text_value).to eq("\n")
        end

        it 'parses other disposition types' do
          text = <<~TEXT
          COURT: NAM:01 19960718 CASC SAN FRANCISCO CO
          CNT:01     #164789
          11360(A) HS-SELL/FURNISH/ETC MARIJUANA/HASH
          DISPO: CLARIFICATION REQUESTED
          TEXT

          tree = parse(text)

          expect(tree.event_identifier).to be_a(EventGrammar::CourtEventIdentifier)

          count_1 = tree.counts[0]
          puts "disposition type: #{count_1.disposition.disposition_type}"
          expect(count_1.disposition.disposition_type).to be_a CountGrammar::OtherDispositionType
        end

        it 'can parse count ranges' do
          text = <<~TEXT
            COURT:
            20040102  SAN FRANCISCO

            CNT: 001-002  #346477
            blah
            CNT: 003-011
            count 3 text
            CNT: 012
            twelve
          TEXT

          tree = parse(text)

          expect(tree.counts[0].count_identifier.start_number.text_value).to eq "001"
          expect(tree.counts[0].count_identifier.end_number.text_value).to eq "002"
          expect(tree.counts[0].text_value).to eq "CNT: 001-002  #346477\nblah\n"

          expect(tree.counts[1].count_identifier.start_number.text_value).to eq "003"
          expect(tree.counts[1].count_identifier.end_number.text_value).to eq "011"
          expect(tree.counts[1].text_value).to eq "CNT: 003-011\ncount 3 text\n"

          expect(tree.counts[2].count_identifier.start_number.text_value).to eq "012"
          expect(tree.counts[2].count_identifier.end_number.text_value).to eq ""
          expect(tree.counts[2].text_value).to eq "CNT: 012\ntwelve\n"
        end

        it 'can parse dates with stray periods' do
          text = <<~TEXT
            COURT:
            20040.102 SAN FRANCISCO

            CNT: 001-004  #346477
            blah
          TEXT

          tree = parse(text)

          expect(tree.date.text_value).to eq '20040.102'
        end

        it 'can parse two digit count' do
          text = <<~TEXT
            COURT:
            20040102  SAN FRANCISCO

            CNT: 01  #346477
            blah
            CNT: 02
            count 2 text
            CNT: 03-04
            count 3/4 text
          TEXT

          tree = parse(text)

          expect(tree.counts[0].text_value).to eq "CNT: 01  #346477\nblah\n"
          expect(tree.counts[1].text_value).to eq "CNT: 02\ncount 2 text\n"
          expect(tree.counts[2].text_value).to eq "CNT: 03-04\ncount 3/4 text\n"
        end

        it 'can parse counts with extra whitespace' do
          text = <<~TEXT
            COURT:
            20040102  SAN FRANCISCO
            CNT : 003
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.counts[0].text_value).to eq "CNT : 003\ncount 3 text\n"
        end

        it 'can parse court identifier with extra whitespace' do
          text = <<~TEXT
            COURT :
            20040102  SAN FRANCISCO
            CNT : 003
            count 3 text
          TEXT

          subject = parse(text)

          expect(subject.event_identifier).to be_a(EventGrammar::CourtEventIdentifier)
        end

        it 'can parse court identifier with preceding whitespace' do
          text = <<~TEXT
               COURT:
            20040102  SAN FRANCISCO
            CNT : 003
            count 3 text
          TEXT

          subject = parse(text)

          expect(subject.event_identifier).to be_a(EventGrammar::CourtEventIdentifier)
        end

        it 'can parse case number even if first CNT number is not 001' do
          text = <<~TEXT
            COURT:
            20040102  SAN FRANCISCO
            CNT : 003 #312145
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.case_number.text_value).to eq('#312145')
        end

        it 'can parse case number even with stray punctuation and newlines' do
          text = <<~TEXT
            COURT:
            20040102  SAN FRANCISCO
            CNT :003.
             . #312145
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.case_number.text_value).to eq('#312145')
        end

        it 'returns nil case number for an unknown case number' do
          text = <<~TEXT
            COURT: NAME7OZ
            19820915 CAMC L05 ANGELES METRO

            CNT: 001
            garbled
            DISPO:CONVICTED
          TEXT

          tree = parse(text)

          expect(tree.case_number).to eq nil
        end

        it 'parses unknown courthouse with TOC on the same line' do
          text = <<~TEXT
            COURT:
            20040102  NEW COURTHOUSE TOC:M
            CNT :003.
             . #312145
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.courthouse.text_value).to eq('NEW COURTHOUSE ')
        end

        it 'parses courthouse with NAM identifier in front' do
          text = <<~TEXT
            COURT:
            20040102
            NAM:001
            NEW COURTHOUSE
            CNT: 001 #312145
            count 3 text
          TEXT

          tree = parse(text)

          expect(tree.courthouse.text_value).to eq('NEW COURTHOUSE')
        end
      end

      context 'parsing an arrest event' do
        it 'parses' do
          text = <<~TEXT
            ARR/DET/CITE:
            NAM:001
            19910105 CAPD CONCORD
            TOC:F
            CNT:001
            #65131
            496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::ArrestEventIdentifier)
          expect(subject.date.text_value).to eq '19910105'
        end

        it 'handles content before the arrest header' do
          text = <<~TEXT
            NAM:001
            ARR/DET/CITE:
            19910105 CAPD CONCORD
            TOC:F
            CNT:001
            #65131
            496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::ArrestEventIdentifier)
          expect(subject.date.text_value).to eq '19910105'
        end

        it 'handles whitespace and stray punctuation in arrest header' do
          text = <<~TEXT
            ARR / DET. / CITE:
            19910105 CAPD CONCORD
            TOC:F
            CNT:001
            #65131
            496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::ArrestEventIdentifier)
          expect(subject.date.text_value).to eq '19910105'
        end
      end

      context 'parsing a custody event' do
        it 'parses' do
          text = <<~TEXT
            CUSTODY:JAIL
            NAM:001
            20120503 CASO MARTINEZ
            CNT:001 #Cc12EA868A-070KLK602
            459 PC-BURGLARY
            TOC:F
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::CustodyEventIdentifier)
          expect(subject.date.text_value).to eq '20120503'
        end

        it 'handles content before the custody header' do
          text = <<~TEXT
            NAM:001
            CUSTODY:JAIL
            20120503 CASO MARTINEZ
            CNT:001 #Cc12EA868A-070KLK602
            459 PC-BURGLARY
            TOC:F
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::CustodyEventIdentifier)
          expect(subject.date.text_value).to eq '20120503'
        end

        it 'handles whitespace and stray punctuation in the header' do
          text = <<~TEXT
             . CUSTODY* *:JAIL
            20120503 CASO MARTINEZ
            CNT:001 #Cc12EA868A-070KLK602
            459 PC-BURGLARY
            TOC:F
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::CustodyEventIdentifier)
          expect(subject.date.text_value).to eq '20120503'
        end
      end

      context 'parsing an applicant event' do
        it 'parses' do
          text = <<~TEXT
            APPLICANT:             NAM:02
            20100715  CASD SOCIAL SERV CCL-CRCB, LOS ANGELES

            CNT:01     #29292929
              APPLICANT ADULT DAY/RESIDENT REHAB

               COM: JKFHKJFKJHS

            20140321
             DISPO:NO LONGER INTERESTED
               COM: AJFH-BJBDHJ
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::ApplicantEventIdentifier)
          expect(subject.date.text_value).to eq '20100715'
          expect(subject.courthouse.text_value).to eq 'CASD SOCIAL SERV CCL-CRCB, LOS ANGELES'
        end
      end

      context 'parsing a probation event' do
        it 'parses' do
          text = <<~TEXT
            PROBATION:             NAM:01
            20100715  CAPR SAN FRANCISCO

            CNT:01     #555787(87)
            11360 HS-SELL/TRANSPORT/ETC MARIJUANA/HASH
            SEN: 3 YEARS PROBATION
            COM: CRT CASE NBR 123488
          TEXT

          subject = parse(text)
          expect(subject.event_identifier).to be_a(EventGrammar::ProbationEventIdentifier)
          expect(subject.date.text_value).to eq '20100715'
          expect(subject.courthouse.text_value).to eq 'CAPR SAN FRANCISCO'
        end
      end
    end
    def parse(text)
      described_class.new.parse(text)
    end
  end
end

