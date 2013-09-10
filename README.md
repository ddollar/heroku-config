# heroku-config

Provides a way for you to push/pull your Heroku environment to use locally.

## Changes in kcolton fork

Added optional --env ENV option to specify a specific .env file to use. Default uses ".env"
Makes maintaining multiple .env files for different enviroments easier
Aimed for parity with foreman --env

## Installation

Add the heroku gem plugin:

    $ heroku plugins:install git://github.com/kcolton/heroku-config.git
    heroku-config installed

Add the following to `.gitignore`:

    .env

## Usage

    # by default, existing keys will not be overwritten
    $ heroku config:pull
    Config for example written to .env

    # optional --overwrite allows you to have the pull overwrite keys
    $ heroku config:pull --overwrite
    Config for example written to .env

    # --interactive will prompt for each value to be overwritten
    $ heroku config:pull --overwrite --interactive
    BUNDLE_DISABLE_SHARED_GEMS: 1
    Overwite? (y/N)

    $ heroku config:push
    Config in .env written to example

    # Optional --env will read and write specified .env file
    $ heroku config:pull --env=envs/stage/.env
    Config for example written to envs/stage/.env

    # --env is philosophy agnostic, use any filename you want
    $ heroku config:push --env=the_best_env_file_ever.potatosalad
    Config in the_best_env_file_ever.potatosalad written to example


## How it works

Your environment will be stored locally in a file named `.env`. This
file can be read by [foreman](http://github.com/ddollar/foreman) to load
the local environment for your app. Similarly, use --env option to specify
.env file to load with foreman

Please remember to not commit your `.env` files to your repository.

## License

MIT License

## Author

David Dollar <ddollar@gmail.com>
