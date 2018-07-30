require "bundler/setup"
require 'ostruct'
require 'fake_application_record'
require "rap_sheet_parser/parser"
require 'rap_sheet_factory'

RSpec.configure do |config|
  config.include RapSheetParser::RapSheetFactory

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def verify_event_looks_like(event, name_code:, date:, case_number:, courthouse:, sentence:)
  expect(event.name_code).to eq name_code
  expect(event.date).to eq date
  expect(event.case_number).to eq case_number
  expect(event.courthouse).to eq courthouse
  expect(event.sentence.to_s).to eq sentence
end

def verify_count_looks_like(count, code_section:, code_section_description:, severity:, disposition:)
  expect(count.code_section).to eq code_section
  expect(count.code_section_description).to eq code_section_description
  expect(count.severity).to eq severity
  expect(count.disposition).to eq disposition
end
