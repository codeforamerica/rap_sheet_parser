require 'spec_helper'

module RapSheetParser
  RSpec.describe CountGrammarParser do
    describe '#parse' do
      it 'parses code sections and disposition' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'

        expect(count.disposition.disposition_type).to be_a CountGrammar::Convicted
        expect(count.disposition.severity.text_value).to eq 'MISDEMEANOR'
        expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL'
        expect(count.disposition.sentence.probation.text_value).to eq '012 MONTHS PROBATION'
        expect(count.disposition.sentence.jail.text_value).to eq '045 DAYS JAIL'
      end

      it 'does not include comments in charge description' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
            COM: SCN-WHO KNOWS
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
        expect(count.comments[0].text_value).to eq "COM: SCN-WHO KNOWS\n"
      end

      it 'does not include the word warrant in code section' do
        text = <<~TEXT
          -WARRANT
          11359 HS-POSSESS MARIJUANA FOR SALE
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'HS'
        expect(count.code_section.section.text_value).to eq '11359'
        expect(count.code_section_description.text_value).to eq 'POSSESS MARIJUANA FOR SALE'
      end

      it 'does not include the words bench warrant in code section' do
        text = <<~TEXT

          -BENCH WARRANT

          11359 HS-POSSESS MARIJUANA FOR SALE
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'HS'
        expect(count.code_section.section.text_value).to eq '11359'
        expect(count.code_section_description.text_value).to eq 'POSSESS MARIJUANA FOR SALE'
      end

      it 'parses multiple count flags' do
        text = <<~TEXT

          -BENCH WARRANT         -PROBATION REVO

          11359 HS-POSSESS MARIJUANA FOR SALE
        TEXT

        count = described_class.new.parse(text)
        expect(count.flags.length).to eq 2
        expect(count.flags[0].text_value.strip).to eq '-BENCH WARRANT'
        expect(count.flags[1].text_value.strip).to eq '-PROBATION REVO'
      end

      it 'does not include arrest by line in charge description' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          ARR BY: CAPD MOUNTAIN VIEW
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
        expect(count.arrest_by.text_value).to eq "ARR BY: CAPD MOUNTAIN VIEW\n"
      end

      it 'does not include TOC in charge description' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY TOC:M
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      end

      it 'does not include warrant number in charge description' do
        text = <<~TEXT
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
            WARRANT #ABCD
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
        expect(count.warrant_number.text_value).to eq "WARRANT #ABCD\n"
      end

      it 'parses when charge is in the comments' do
        text = <<~TEXT
           SEE COMMENT FOR CHARGE
          DISPO:CONVICTED
          CONV STATUS:FELONY
          COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
          COM: CNT 01 CHRG-484-487 (A) PC SECOND DEGREE TOMFOOLERY
          DCN:T11389422131233123000545
        TEXT

        count = described_class.new.parse(text)
        expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
        expect(count.disposition.disposition_type).to be_a CountGrammar::Convicted

        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '484-487 (A)'
        expect(count.code_section_description.text_value).to eq 'SECOND DEGREE TOMFOOLERY'
      end

      it 'handles stray information when charge is in the comments' do
        text = <<~TEXT
          SEE COMMENT FOR CHARGE
          TOC:N
          Page 22 of 26
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: IMP SEN SS, 003 YEARS PROBATION, 020 DAYS JAIL, FINE
          COM: CNT 01 CHRG-594(A)-(B) (2) (A) PC DEFRAUDING AN ARMADILLO TOC:F
          DCN:10000000000000000007
        TEXT

        count = described_class.new.parse(text)
        expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
        expect(count.disposition.disposition_type).to be_a CountGrammar::Convicted
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '594(A)-(B) (2) (A)'
        expect(count.code_section_description.text_value).to eq 'DEFRAUDING AN ARMADILLO'
      end

      it 'parses when charge is in the comments but missing disposition' do
        text = <<~TEXT
          SEE COMMENT FOR CHARGE
        TEXT

        count = described_class.new.parse(text)
        expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
        expect(count.code_section).to be_nil
      end

      it 'parses malformed charge comments' do
        text = <<~TEXT
           SEE. COMMENT FOR CHARGE
          DISPO:CONVICTED
          CONV STATUS:FELONY
          COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
          .COM; CHRG 490,2 PC
          DCN:T11389422131233123000545
        TEXT

        count = described_class.new.parse(text)
        expect(count.charge_line).to be_a CountGrammar::SeeCommentForCharge
        expect(count.disposition.disposition_type).to be_a CountGrammar::Convicted
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '490,2'
      end

      it 'parses code section when sentencing line exists' do
        text = <<~TEXT
           .1170 (H) PC-SENTENCING
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      end

      it 'parses count updates' do
        text = <<~TEXT
          11359 HS-POSSESS MARIJUANA FOR SALE
          20040813
          DISPO:PROS DEFERRED FOR REVOCATION OF PAROLE

          20060101
          DISPO:SENTENCE MODIFIED
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'HS'
        expect(count.code_section.section.text_value).to eq '11359'
        expect(count.code_section_description.text_value).to eq 'POSSESS MARIJUANA FOR SALE'

        expect(count.updates.length).to eq 2

        expect(count.updates[0].date.text_value).to eq '20040813'
        expect(count.updates[0].dispositions[0].text_value).to eq "DISPO:PROS DEFERRED FOR REVOCATION OF PAROLE\n\n"

        expect(count.updates[1].date.text_value).to eq '20060101'
      end

      it 'parses count updates when disposition present' do
        text = <<~TEXT
          11359 HS-POSSESS MARIJUANA FOR SALE
          DISPO:CONVICTED
          20040813
          DISPO:PROS DEFERRED FOR REVOCATION OF PAROLE
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'HS'
        expect(count.code_section.section.text_value).to eq '11359'
        expect(count.code_section_description.text_value).to eq 'POSSESS MARIJUANA FOR SALE'

        expect(count.updates[0].date.text_value).to eq '20040813'
        expect(count.updates[0].dispositions[0].text_value).to eq "DISPO:PROS DEFERRED FOR REVOCATION OF PAROLE\n"
      end

      it 'parses out punctuation around code section' do
        text = <<~TEXT
            .496. PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section.code.text_value).to eq 'PC'
        expect(count.code_section.section.text_value).to eq '496'
        expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      end

      it 'ignores "TRAFFIC VIOLATION" when looking for conviction codes' do
        text = <<~TEXT
          TRAFFIC VIOLATION
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 003 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section).to be_nil
      end

      it 'parses applicant counts' do
        text = <<~TEXT
            APPLICANT ADULT DAY/RESIDENT REHAB

             COM: JKFHKJFKJHS

          20140321
           DISPO:NO LONGER INTERESTED
             COM: AJFH-BJBDHJ
        TEXT

        count = described_class.new.parse(text)
        expect(count.code_section).to be_nil

        expect(count.disposition.text_value).to be_empty
        expect(count.comments[0].text_value).to eq "COM: JKFHKJFKJHS\n\n"
        expect(count.updates[0].dispositions[0].text_value).to eq " DISPO:NO LONGER INTERESTED\n   COM: AJFH-BJBDHJ\n"
      end
      context 'when page number breaks up a count or code section' do
        it 'does not include the page number in code sections' do
          text = <<~TEXT
                        Page 12 of 29
              496.3(A)(2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
            *DISPO:CONVICTED
              CONV STATUS:MISDEMEANOR
              SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          TEXT

          count = described_class.new.parse(text)
          expect(count.code_section.code.text_value).to eq 'PC'
          expect(count.code_section.section.text_value).to eq '496.3(A)(2)'
          expect(count.code_section.text_value).to eq '496.3(A)(2) PC'
          expect(count.code_section_description.text_value).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
        end
      end
    end
  end
end
