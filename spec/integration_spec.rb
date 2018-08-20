require 'fog/aws'
require 'fog/local'

RSpec.describe 'integration', integration: true do
  let(:directory) do
    connection = Fog::Storage.new(fog_params)
    connection.directories.new(key: 'redacted-rap-sheets')
  end

  it 'parses without errors' do
    directory.files.map(&:key).each do |rap_sheet|
      parse_rap_sheet(rap_sheet)
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
