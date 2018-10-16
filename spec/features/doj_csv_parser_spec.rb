require 'rap_sheet_parser'
require 'awesome_print'

RSpec.describe 'doj csv parsing' do
  let(:doj_csv) { File.join(File.path(__dir__), '..', 'fixtures', 'cadoj.csv') }
  it 'parses files correctly' do
    rap_sheet = RapSheetParser::Parser.new.parse_from_csv(doj_csv)

    expect(rap_sheet.cycles.length).to eq 2

    cycle1 = rap_sheet.cycles[0]
    expect(cycle1.events.length).to eq 2
    verify_event_looks_like(cycle1.events[0], name_code: nil, date: Date.new(1979, 5, 25), case_number: nil, courthouse: 178366, sentence: nil)
  end
end
