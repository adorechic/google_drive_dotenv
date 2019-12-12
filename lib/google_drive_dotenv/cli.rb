require 'thor'
require 'google_drive'

module GoogleDriveDotenv
  class CLI < Thor
    desc "export [key]", "Export Spreadsheet to env file"
    def export(key)
      session = GoogleDrive::Session.from_config(File.expand_path("~/google_config.json"))

      sheet = session.spreadsheet_by_key(key).worksheets[0]
      File.open('.env', 'wb') do |file|
        (1..sheet.num_rows).each do |row|
          key = sheet[row, 1]
          value = sheet[row, 2]
          file.puts([key, value].join('='))
        end
      end
    end
  end
end
