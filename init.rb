require "config/heroku/command/config"

if Heroku::VERSION >= "2.0"
  # specify a specific filename to use
  Heroku::Command.global_option :filename, "-f", "--filename FILENAME"
end

begin
  require "heroku-api"
rescue LoadError
  puts <<-MSG
  heroku-config - requires the heroku-api gem. Please install:

  gem install heroku-api
  MSG
  exit
end
