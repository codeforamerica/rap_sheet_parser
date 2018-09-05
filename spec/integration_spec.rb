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
      actual_values = to_hash(rap_sheet)

      expect(expected_values).to eq actual_values
    end

    all_files_without_expectations = all_text_files.reject do |f|
      expectations_filename = f.gsub('.txt', '.jsonq')
      all_files.include?(expectations_filename)
    end

    all_files_without_expectations.each do |rap_sheet_textfile|
      parse_rap_sheet(rap_sheet_textfile)
    end
  end

  def to_hash(rap_sheet)
    cycles = rap_sheet.cycles.map do |cycle|
      events = cycle.events.map do |event|
        counts = event.counts.map do |count|
          disposition =
            if count.disposition
              {
                type: count.disposition.type,
                text: count.disposition.text,
                severity: count.disposition.severity,
                sentence: count.disposition.sentence.to_s
              }
            end

          {
            code_section: count.code_section,
            code_section_description: count.code_section_description,
            disposition: disposition
          }
        end

        {
          header: event.header,
          date: event.date.strftime('%m/%d/%Y'),
          agency: event.agency,
          counts: counts
        }
      end

      {
        events: events
      }
    end

    {
      cycles: cycles
    }
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
        local_root: ENV['LOCAL_ROOT']
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
