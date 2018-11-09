require 'fog/aws'
require 'fog/local'
require 'json'

RSpec.describe 'integration', integration: true do
  let(:directory) do
    if ENV['LOCAL_RAP_SHEETS_DIR']
      Fog::Storage.new(
        provider: 'Local',
        local_root: "#{ENV['LOCAL_RAP_SHEETS_DIR']}"
      ).directories.new(key: '.')

    else
      Fog::Storage.new(
        provider: 'aws',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_KEY']
      ).directories.new(key: ENV['RAP_SHEETS_BUCKET'])
    end
  end

  it 'parses files correctly' do
    all_files = directory.files.map(&:key)
    puts "Found #{all_files.length} files"
    all_files_with_expectations = all_files.select do |f|
      f.start_with?('with_assertions') && f.end_with?('.txt')
    end
    puts "Found #{all_files_with_expectations.length} files with expectations"

    all_files_with_expectations.each do |rap_sheet_textfile|
      rap_sheet = parse_rap_sheet(rap_sheet_textfile)

      expectations_filename = rap_sheet_textfile.gsub('.txt', '.json')
      expected_values = JSON.parse(directory.files.get(expectations_filename).body, symbolize_names: true)
      actual_values = to_hash(rap_sheet)

      actual_personal_info = actual_values[:personal_info]
      expected_personal_info = expected_values[:personal_info]
      expect(actual_personal_info).to eq(expected_personal_info), "#{rap_sheet_textfile}: Expected #{expected_personal_info}, got #{actual_personal_info}"

      actual_cycles = actual_values[:cycles]
      expected_cycles = expected_values[:cycles]
      expect(actual_cycles.length).to eq(expected_cycles.length), "#{rap_sheet_textfile}: Expected #{expected_cycles.length}, got #{actual_cycles.length}"
      actual_cycles.each.with_index do |cycle, cycle_index|
        actual_events = cycle[:events]
        expected_events = expected_cycles[cycle_index][:events]
        message = "#{rap_sheet_textfile}, Cycle #{cycle_index + 1}: Expected #{expected_events.length}, got #{actual_events.length}"
        expect(actual_events.length).to eq(expected_events.length), message

        actual_events.each.with_index do |event, event_index|
          message = "Mismatch in #{rap_sheet_textfile}: Cycle #{cycle_index + 1}, Event #{event_index + 1}"
          expect(event).to eq(expected_events[event_index]), message
        end
      end
    end
  end

  it 'parses files without errors' do
    all_files = directory.files.map(&:key)

    all_files_without_expectations = all_files.select do |f|
      !f.start_with?('with_assertions') && f.end_with?('.txt')
    end

    all_files_without_expectations.each.with_index do |rap_sheet_textfile, index|
      puts "Processed #{index} RAP sheets" if index % 50 == 0

      parse_rap_sheet(rap_sheet_textfile)
    rescue StandardError
      puts "Error in #{rap_sheet_textfile}"
      raise
    end
  end

  def to_hash(rap_sheet)
    personal_info = {
      cii: rap_sheet.personal_info.cii,
      sex: rap_sheet.personal_info.sex,
      names: Hash[rap_sheet.personal_info.names.map { |k, v| [k.to_sym, v] }],
      date_of_birth: rap_sheet.personal_info.date_of_birth.strftime('%m/%d/%Y'),
      race: rap_sheet.personal_info.race
    }

    cycles = rap_sheet.cycles.map do |cycle|
      events = cycle.events.map do |event|
        counts = event.counts.map do |count|
          disposition =
            if count.disposition
              {
                type: count.disposition.type,
                text: count.disposition.text,
                severity: count.disposition.severity,
                sentence: count.disposition.sentence&.to_s
              }.compact
            end

          {
            code_section: count.code_section,
            code_section_description: count.code_section_description,
            disposition: disposition
          }.compact
        end

        {
          header: event.event_type,
          date: event.date.strftime('%m/%d/%Y'),
          agency: event.agency,
          counts: counts
        }.compact
      end

      {
        events: events
      }.compact
    end

    { personal_info: personal_info, cycles: cycles }.compact
  end

  def parse_rap_sheet(filename)
    text = directory.files.get(filename).body.force_encoding('utf-8')
    RapSheetParser::Parser.new.parse(text)
  rescue StandardError
    puts "error in file #{filename}"
    raise
  end
end
