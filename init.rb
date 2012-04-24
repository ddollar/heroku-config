require "config/heroku/command/config"

if Heroku::VERSION >= "2.0"
  Heroku::Command.global_option :filename, "--filename FILENAME"
  Heroku::Command.global_option :appenv, "--appenv"
end