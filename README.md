# Locale

[![Build status](https://secure.travis-ci.org/Locale/localeapp.png)](http://travis-ci.org/Locale/localeapp)
[![Code Climate](https://codeclimate.com/github/Locale/localeapp.png)](https://codeclimate.com/github/Locale/localeapp)
[![Gem Version](https://badge.fury.io/rb/localeapp.png)](http://badge.fury.io/rb/localeapp)

The localeapp gem connects your rails app to the Locale service on http://www.localeapp.com. Locale makes hand editing translation files something you don't have to do.

The gem hooks into the i18n exception mechanism to send missing translations to the app. When translated content has been added it's automatically pulled down so you can see it straight away.

## Security

Though the i18n gem uses YAML as it's default file format it doesn't require serialization of ruby objects. To prevent the kind of security problems detailed in [CVE-2013-0156][1] the localeapp gem will not load any YAML containing the string !ruby/ as of version 0.6.9.

## Installation

### Rails 3

Add the localeapp gem to your `Gemfile` and install it:

    echo "gem 'localeapp'" >> Gemfile
    bundle install

Create a project on localeapp.com and get the api key. Then run:

    bundle exec localeapp install <YOUR_API_KEY>

This will check everything looks good and create `config/initializers/localeapp.rb` for you.

### Rails 2.3

Define localeapp in `config/environment.rb`:

    config.gem 'localeapp'

Install the gem:

    rake gems:install

Create a project on localeapp.com and get the api key. Then run:

    localeapp install <YOUR_API_KEY>

### Non rails projects

Install the gem and run:

    localeapp install --standalone <YOUR_API_KEY>

This will create a `.localeapp` directory for your configuration files.

### Public projects

Install the gem and run:

    localeapp install --github <YOUR_API_KEY>

This will create a skeleton project you can push to `<your_gem>-i18n` on github.  You get a `.localeapp` directory for your configuration files, a `locales` directory for the yaml, a `.gitignore` file that ignores `.localeapp` and a `README.md` explaining to translators how to find the project on localeapp.com.

## Importing existing content

You can import via localeapp.com or with the command line tool. To import existing translations do:

    localeapp push config/locales/en.yml

This will queue importing the file. The projects pages on localeapp.com will automatically refresh so you can see the import progress.

If you've more than one locale to import you can import all files in a directory:

    localeapp push config/locales/

## Default Rails Translations

Locale will automatically add the standard rails translations when a project is created. If for some reason you don't want these, you can remove them using in the project libraries area on localeapp.com

## Automatically sending missing translations

Missing translations are automatically sent only in the development environment by default. When a page is refreshed any missing translations will be sent to localeapp.com.

If you want to disable sending missing translations in the development environment then edit `config/initializers/localeapp.rb` to include:

    config.sending_environments = []

This is just an array, so you can configure it to match send in any environment you wish.

## Manually create translations

You can create translations on the command line by running:

    localeapp add key.name en:"test content" es:"spanish content"

You must provide at least one translation and the locale code must already exist in the project.

## Automatically pulling translations

There are two ways to do this, one that suits a single developer working the code locally and one where the translations are being pulled down to a staging (or live) server.

### Single developer

In this mode the gem pulls any updated translations from localeapp.com at the beginning of each request. This is the default setting so you don't need to do anything special.

### Staging server

In this mode you configure the individual listeners to not poll every request and instead run localeapp in daemon mode to fetch updated translations. This is useful when you have more than one listener and don't want them to race to update the translations.

#### Disabling polling

Edit config/initializers/localeapp.rb to include:

    config.polling_environments = []

Run the daemon with:

    localeapp daemon

The listeners will automatically reload translations when they see there are new ones. The daemon has two options:

  -b will run in the background and put a pid file in tmp/pids/localeapp.pid
  -i X will change the polling interval to X from it's default five seconds.

### Disabling Reloading

Automatic reloading is only enabled in the development environment by default and can be disabled in a similar way to polling and sending:

    config.reloading_environments = []

### Blacklisting keys and namespaces (Rails only)

To prevent certain missing translations from being sent to the Locale servers - in case of automatically generated keys from a gem for example - you can configure the `blacklisted_keys_pattern` option with a regular expression.

For example, to prevent all keys containing the word "simple_form" :

    config.blacklisted_keys_pattern = /simple_form/

### Caching

To prevent localeapp from sending translations every time they are missing, add this config setting:

    config.cache_missing_translations = true

## Inviting other developers and translators

You can invite other developers and translators via localeapp.com.  Developers have access to all the content and all the locales. Translators are restricted to editing only the locales you give them access too.

## Adding a locale

If we find an unknown locale during an import we'll add it to your project. You can also add a new locale to a project via localeapp.com. This will create missing translations for every translation key. You will need to restart any listeners completely to pick up the new locale.

## Syck, Psych, and creating YAML

Since ruby 1.9.3-p0 Psych has been the default YAML engine in Ruby. Psych is based on libyaml and fixes a number of issues with the previous YAML library, Syck. localeapp.com uses 1.9.3 and Psych for all its YAML processing. The localeapp gem will use Psych if it is available but falls back to the ya2yaml library if not. ya2yaml supports UTF-8 (which Syck doesn't handle very well) but it does write YAML differently to Psych so you will notice differences between exporting directly from localeapp.com and doing localeapp pull on the command line unless you're using 1.9.3+ or have installed Psych as a gem.

## Proxies

If you need to go through a proxy server, you can configure it with:

    config.proxy = "http://my.proxy.com:8888"

## SSL Certificate verification

localeapp.com uses https everywhere but certificate validation is turned off by default. This is because ruby doesn't know how to read the certs from the OSX keychain. You can turn verification on and tell the gem where the latest CA certificates are by adding:

    config.ssl_verify = true
    config.ssl_ca_file = /path/to/ca_cert.pm

See [this article on Ruby Inside][2] for some more details.

## Support and feedback

You can contact us via the support link at the bottom of the page or emailing support@localeapp.com

## Contributing

See corresponding [contributing guidelines][3].

## License

Copyright (c) 2014 [Locale][5] and other [contributors][6], released under the [MIT License][4].

[1]: https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
[2]: http://www.rubyinside.com/how-to-cure-nethttps-risky-default-https-behavior-4010.html
[3]: https://github.com/Locale/localeapp/blob/master/CONTRIBUTING.md
[4]: http://opensource.org/licenses/MIT
[5]: https://github.com/Locale
[6]: https://github.com/Locale/localeapp/graphs/contributors
