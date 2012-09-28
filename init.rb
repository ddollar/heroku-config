require "config/heroku/command/config"

begin
  require "heroku-api"
rescue LoadError
  puts <<-MSG
  This plugin is not compatiable with the version of Heroku CLI installed. If
  you have installed the Heroku gem, please upgrade with the following command:

  gem update heroku
  MSG
  exit
end
