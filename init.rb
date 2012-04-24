require "config/heroku/command/config"

if Heroku::VERSION >= "2.0"
  # specify a specific filename to use
  Heroku::Command.global_option :filename, "--filename FILENAME"
  # option to use an .env file per app (e.g. heroku-app-name.env)
  Heroku::Command.global_option :multi, "--multi", "-m"
end