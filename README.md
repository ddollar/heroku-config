# heroku-config

Provides a way for you to push/pull your Heroku environment to use locally.

## Installation

Add the heroku gem plugin:

    $ heroku plugins:install git://github.com/ddollar/heroku-config.git
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
    
    # only pull a subset of keys (default is to pull all keys)
    $ heroku config:pull DATABASE_URL RAILS_ENV
    Will only pull DATABASE_URL and RAILS_ENV keys to .env

    $ heroku config:push
    Config in .env written to example

    # Optional --env will use specific env file
    $ heroku config:pull --env=production.env
    Config for example written to production.env

## How it works

Your environment will be stored locally in a file named `.env`. This
file can be read by [foreman](http://github.com/ddollar/foreman) to load
the local environment for your app.

To use a file other than the default `.env`, use the --env parameter.

Please remember to not commit your `.env` files to your repository.

## License

MIT License

## Author

David Dollar <ddollar@gmail.com>
