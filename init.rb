require "config/heroku/command/config"

begin
  require "heroku-api"
rescue LoadError
  puts <<-MSG
  heroku-config - requires the heroku-api gem. Please install:

  gem install heroku-api
  MSG
  exit
end
