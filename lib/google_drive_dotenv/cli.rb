require 'thor'
require 'google_drive'
require 'sinatra/base'
require 'launchy'


module GoogleDriveDotenv
  class App < Sinatra::Base
    class << self
      attr_accessor :credentials, :output, :key

      def export_env(authorization_code)
        credentials.code = authorization_code
        credentials.fetch_access_token!

        session = GoogleDrive::Session.from_credentials(credentials)

        sheet = session.spreadsheet_by_key(key).worksheets[0]
        File.open(output, 'wb') do |file|
          (1..sheet.num_rows).each do |row|
            key = sheet[row, 1]
            value = sheet[row, 2]
            file.puts([key, value].join('='))
          end
        end

      end
    end

    get '/' do
      self.class.export_env(params['code'])
      body "Successfully export env!"
      self.class.quit!
    end
  end

  class CLI < Thor
    desc "export [key]", "Export Spreadsheet to env file"
    option "output", aliases: "o", type: :string, default: ".env"
    option "config", aliases: "c", type: :string, default: "~/google_config.json"
    def export(key)
      config_path = File.expand_path(options['config'])

      unless File.exist?(config_path)
        raise "Please put #{config_path}"
      end

      auth_config = GoogleDrive::Config.new(config_path)
      auth_config.scope ||= GoogleDrive::Session::DEFAULT_SCOPE

      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: auth_config.client_id,
        client_secret: auth_config.client_secret,
        scope: auth_config.scope,
        redirect_uri: 'http://localhost:4567',
      )

      Launchy.open(credentials.authorization_uri)
      App.credentials = credentials
      App.output = options['output']
      App.key = key
      App.run!
    end
  end
end
