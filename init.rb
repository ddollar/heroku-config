require "config/heroku/command/config"

begin
  require "heroku-api"
rescue LoadError
  puts <<-MSG
  heroku-config - This plugin is not compatiable with the version of Heroku CLI
  installed. Please upgrade to the Heroku Toolbelt at:

  https://toolbelt.heroku.com
  MSG
  exit
end
