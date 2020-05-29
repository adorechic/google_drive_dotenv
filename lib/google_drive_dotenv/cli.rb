require 'thor'
require 'google_drive'

module GoogleDriveDotenv
  class CLI < Thor
    desc "export [key]", "Export Spreadsheet to env file"
    option "output", aliases: "o", type: :string, default: ".env"
    option "config", aliases: "c", type: :string, default: "~/google_config.json"
    def export(key)
      config_path = File.expand_path(options['config'])

      unless File.exist?(config_path)
        raise "Please put #{config_path}"
      end

      session = GoogleDrive::Session.from_config(config_path)

      sheet = session.spreadsheet_by_key(key).worksheets[0]
      File.open(options['output'], 'wb') do |file|
        (1..sheet.num_rows).each do |row|
          key = sheet[row, 1]
          value = sheet[row, 2]
          file.puts([key, value].join('='))
        end
      end
    end
  end
end
