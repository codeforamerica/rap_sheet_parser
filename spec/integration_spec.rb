require 'fog/aws'
require 'fog/local'
require 'json'

RSpec.describe 'integration', integration: true do
  let(:directory) do
    connection = Fog::Storage.new(fog_params)
    connection.directories.new(key: 'redacted-rap-sheets')
  end

  it 'parses without errors' do
    all_files = directory.files.map(&:key)

    all_text_files = all_files.select { |f| f.end_with? '.txt' }

    all_files_with_expectations = all_text_files.select do |f|
      expectations_filename = f.gsub('.txt', '.json')
      all_files.include?(expectations_filename)
    end

    all_files_with_expectations.each do |rap_sheet_textfile|
      rap_sheet = parse_rap_sheet(rap_sheet_textfile)

      expectations_filename = rap_sheet_textfile.gsub('.txt', '.json')
      expected_values = JSON.parse(directory.files.get(expectations_filename).body, symbolize_names: true)

      rap_sheet.cycles.each.with_index do |cycle, cycle_index|
        expected_cycle = expected_values[:cycles][cycle_index]

        cycle.events.each.with_index do |event, event_index|
          expected_event =expected_cycle[:events][event_index]

          expect_events_match(event, expected_event)
        end
      end
    end

    all_files_without_expectations = all_text_files.reject do |f|
      expectations_filename = f.gsub('.txt', '.json')
      all_files.include?(expectations_filename)
    end

    all_files_without_expectations.each do |rap_sheet_textfile|
      parse_rap_sheet(rap_sheet_textfile)
    end
  end

  def expect_events_match(actual, expected)
    expect(actual.header).to eq expected[:header]
    expect(actual.date).to eq Date.strptime(expected[:date], '%m/%d/%Y')
    expect(actual.agency).to eq expected[:agency]

    actual.counts.each.with_index do |count, count_index|
      expected_count = expected[:counts][count_index]
      expect(count.code_section).to eq expected_count[:code_section]
      expect(count.code_section_description).to eq expected_count[:code_section_description]
      expect(count.severity).to eq expected_count[:severity]
      expect(count.disposition).to eq expected_count[:disposition]
    end
  end

  def parse_rap_sheet(filename)
    text = directory.files.get(filename).body.force_encoding('utf-8')
    RapSheetParser::Parser.new.parse(text)
  rescue
    puts "error in file #{filename}"
    raise
  end

  def fog_params
    if ENV['LOCAL_ROOT']
      {
        provider: 'Local',
        local_root: ENV['LOCAL_ROOT'],
      }
    else
      {
        provider: 'aws',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_KEY']
      }
    end
  end
end
