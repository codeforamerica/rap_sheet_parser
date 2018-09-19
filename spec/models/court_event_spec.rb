require 'spec_helper'

module RapSheetParser
  RSpec.describe CourtEvent do
    describe '#severity' do
      it 'returns the highest severity found within the counts' do
        event = build_court_event(
          counts: [
            build_count(disposition: build_disposition(severity: 'F')),
            build_count(disposition: nil)
          ]
        )
        expect(event.severity).to eq 'F'

        event = build_court_event(
          counts: [
            build_count(disposition: build_disposition(severity: 'I')),
            build_count(disposition: build_disposition(severity: 'F'))
          ]
        )
        expect(event.severity).to eq 'F'

        event = build_court_event(
          counts: [
            build_count(disposition: build_disposition(severity: 'I')),
            build_count(disposition: build_disposition(severity: 'M'))
          ]
        )
        expect(event.severity).to eq 'M'

        event = build_court_event(
          counts: [
            build_count(disposition: build_disposition(severity: 'I')),
            build_count(disposition: build_disposition(severity: 'I'))
          ]
        )
        expect(event.severity).to eq 'I'
      end
    end

    describe '#successfully_completed_duration?' do
      let(:conviction_date) { Date.new(1994, 1, 2) }
      let(:conviction_event) { build_court_event(date: conviction_date) }

      it 'returns false if any arrests within probation period' do
        arrest_event = build_arrest_event(date: Date.new(1994, 6, 2))
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any custody events within probation period' do
        custody_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], event_type: 'custody')
        rap_sheet = build_rap_sheet(events: [conviction_event, custody_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any probation events within probation period' do
        probation_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], event_type: 'probation')
        rap_sheet = build_rap_sheet(events: [conviction_event, probation_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any supplemental arrest events within probation period' do
        supplemental_arrest_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], event_type: 'supplemental_arrest')
        rap_sheet = build_rap_sheet(events: [conviction_event, supplemental_arrest_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'returns false if any mental health events within probation period' do
        mental_health_event = build_other_event(date: Date.new(1994, 6, 2), counts: [], event_type: 'mental_health')
        rap_sheet = build_rap_sheet(events: [conviction_event, mental_health_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq false
      end

      it 'skips events without dates' do
        arrest_no_date_event = build_arrest_event(date: nil)
        rap_sheet = build_rap_sheet(events: [conviction_event, arrest_no_date_event])

        expect(conviction_event.successfully_completed_duration?(rap_sheet, 1.year)).to eq true
      end

      it 'returns nil if event does not have a date' do
        conviction_event_missing_date = build_court_event(date: nil)
        arrest_no_date_event = build_arrest_event(date: nil)
        events = build_rap_sheet(events: [conviction_event_missing_date, arrest_no_date_event]).events

        expect(conviction_event_missing_date.successfully_completed_duration?(events, 1.year)).to be_nil
      end
    end

    describe '#probation_violated?' do
      let(:sentence) { ConvictionSentence.new(probation: 1.year) }
      let(:conviction_event) { build_court_event(date: Date.new(1994, 1, 2), counts: [count]) }
      let(:count) { build_count(disposition: build_disposition(sentence: sentence)) }
      let(:rap_sheet) do
        build_rap_sheet(events: [conviction_event, build_arrest_event(date: arrest_date)])
      end

      context 'if there are violating events within the probation period' do
        let(:arrest_date) { Date.new(1994, 6, 2) }
        it 'returns true' do
          expect(conviction_event.probation_violated?(rap_sheet)).to eq true
        end
      end

      context 'if there are no violating events within the probation period' do
        let(:arrest_date) { Date.new(1996, 6, 2) }
        it 'returns false' do
          expect(conviction_event.probation_violated?(rap_sheet)).to eq false
        end
      end

      context('if the event does not include probation') do
        let(:arrest_date) { Date.new(1994, 6, 2) }
        let(:sentence) { ConvictionSentence.new(jail: 1.year) }
        it 'returns false' do
          expect(conviction_event.probation_violated?(rap_sheet)).to eq false
        end
      end
    end

    describe '#sentence' do
      it 'sets sentence correctly if sentence modified' do
        event = build_court_event(
          counts: [
            build_count(
              disposition: build_disposition(
                sentence: ConvictionSentence.new(probation: 12.months)
              ),
              updates: [
                Update.new(
                  dispositions: [
                    build_disposition(type: 'sentence_modified',
                                      sentence: ConvictionSentence.new(jail: 5.years))
                  ]
                )
              ]
            )
          ]
        )

        expect(event.sentence.jail).to eq 5.years
      end

      it 'sets sentence correctly if no sentence modification' do
        event = build_court_event(
          counts: [
            build_count(
              disposition: build_disposition(
                sentence: ConvictionSentence.new(probation: 12.months)
              ),
              updates: []
            )
          ]
        )

        expect(event.sentence.probation).to eq 12.months
      end

      it 'sets sentence correctly if no sentence' do
        event = build_court_event(
          counts: [
            build_count(
              disposition: build_disposition(sentence: nil)
            )
          ]
        )

        expect(event.sentence).to eq nil
      end
    end

    describe '#dismissed_by_pc1203?' do
      it 'returns true if pc1203 dismissed update present' do
        event = build_court_event(
          counts: [
            build_count(
              updates: [
                Update.new(dispositions: [build_disposition(type: 'pc1203_dismissed')])
              ]
            )
          ]
        )

        expect(event.dismissed_by_pc1203?).to eq true
      end

      it 'returns false if pc1203 dismissed update missing' do
        event = build_court_event

        expect(event.dismissed_by_pc1203?).to eq false
      end
    end

    describe '#has_sentence_with?' do
      it 'returns true if any counts have a disposition with a sentence including specified type' do
        event = build_court_event(
          counts: [
            build_count(
              disposition: build_disposition(
                sentence: ConvictionSentence.new(probation: 12.months, jail: 2.years)
              )
            ),
            build_count(
              disposition: build_disposition(
                sentence: ConvictionSentence.new(jail: 1.month)
              )
            ),
            build_count(disposition: build_disposition(sentence: nil)),
            build_count(disposition: nil)
          ]
        )

        expect(event.has_sentence_with?(:probation)).to eq true
        expect(event.has_sentence_with?(:prison)).to eq false
        expect(event.has_sentence_with?(:jail)).to eq true

        expect { event.has_sentence_with? :foo }.to raise_error NoMethodError
      end
    end
  end
end
