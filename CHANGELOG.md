# master

# Version 3.1.3

* Fix deprecation warning in Rails 6 initialization (thanks to [@ryanb](https://github.com/ryanb) for [reporting it](https://github.com/Locale/localeapp/issues/276))

# Version 3.1.2

* Fix a bug when `.env` is a directory (thanks to [@xijo](https://github.com/xijo) for [reporting it](https://github.com/Locale/localeapp/pull/262))

# Version 3.1.1

* Remove I18n Hash#deep_merge! usage
* Support ruby 2.6

# Version 3.1.0

* add `localeapp cp`

# Version 3.0.1

* actually prevent `CVE-2013-0269 / OSVDB-101137` (3.0.0 was supposed to)

# Version 3.0.0

* drop support for i18n 0.4, 0.5 and 0.6 (ℹ️ Rails [dropped those in July 2014](https://github.com/rails/rails/commit/cd7d414e48f537278043bfc77cfb4217e8c89c24)))
* add official support for i18n 0.8, 0.9 and 1.0
* prevent users to use dependencies impacted by some vulnerabilities:
  * OSVDB-101157
  * CVE-2015-3448 / OSVDB-117461
  * CVE-2013-0269 / OSVDB-101137
  * CVE-2015-1820 / OSVDB-119878
* fix a bug introduced in 2.5.0 where the exception handler was crashing with `TypeMismatch` error when `blacklisted_keys_pattern` was not explicitly configured

# Version 2.5.0

* Show fully-scoped keys in `ExceptionHandler` log messages (thanks to [@leonhooijer](https://github.com/leonhooijer))
* Don't force raising an exception for blacklisted keys (thanks to [@leonhooijer](https://github.com/leonhooijer))

# Version 2.4.0

* Support pulling of single locales (thanks to [@full-of-foo](https://github.com/full-of-foo))

# Version 2.3.0

* Report import identifier on push success

# Version 2.2.0

* Read API key from environment in generated config files, instead of
  writing the API key directly in those files
* Fix handling of HTTP errors when querying API
* Stop checking project and app default locale at install

# Version 2.1.1

* Support ruby 2.4

# Version 2.1.0

* Drop ruby 1.9 and ruby 2.0 support

# Version 2.0.0

* Drop i18n 0.3.x and rails 2.x support
* Remove rack dependency

# Version 1.0.2

* Fix a XSS vulnerability where translations keys could contain unescaped HTML (thanks to [@grekko](https://github.com/grekko))

# Version 1.0.1

* Fix error when bundling with Rails >= 4.2 (due to a dependency on i18n < 0.7)

# Version 1.0

* Drop support for Ruby 1.9.2
* Adopt semantic versioning
* Upgrade test frameworks to RSpec 3 and Cucumber 2

# Version 0.9.3

* Support multilines translations content in `localeapp add`

# Version 0.9.2

* Refactor which monkeypatch/backported-bugfix is loaded for which Rails version
* Hotfix a regression where calling `I18n.t(nil)` would end up in a an error in MimicRailsMissingTranslationDisplay

# Version 0.9.1

* Fix Rails 4.1 TranslationHelper regression

# Version 0.9.0

* Add option to configure SSL version used

# Version 0.8.1

* Add the `blacklisted_keys_pattern` configuration option
* Prevent blacklisted keys from being sent to Locale servers in the Rails exception handler

# Version 0.8.0

* Fix problem with line ending in three dots. (thanks to [@holli](https://github.com/holli))
* Change deprecated File.exists? to File.exist?
* Fix "install --github" so it appends README.md. Before it truncated the README.md file with new content, now it appends content in a more correct manner.
* Fix .gitignore injection so it ensures a newline.
* Extract synchronisation data into SyncFile and SyncData classes. These value objects allow us to read synchronisation data from yaml files that have both strings and symbols as keys. Sync files now use strings as keys when serialising to yaml. If you find that you have a log/localeapp.yml file that contains the string !ruby, run localeapp pull to update to "regular" yaml syntax.
* Tweak Aruba config for jRuby (development related only).
* Fix minor typo in "updater" output message.

# Version 0.7.2

* Display a message when the timestamp used for an update command is too old
* Do not even try to hit the API when this timestamp is too old (since the API will return a 422 error anyway)

# Version 0.7.1

* Raise Localeapp::MissingApiKey when api_key is empty

# Version 0.7.0

* Drop support for Ruby 1.8 (both MRI and JRuby)
* Add support for Ruby 2.0 and 2.1 (both MRI and JRuby)
* Mimic new Rails `translate` helper behaviour, which is to wrap missing translations messages in <span> elements
* Fix missing translations sending with Rails >= 3.2.16 and >= 4.0.2

# Version 0.6.14

* Fix a bug where the last poll and last refresh date could be nil

# Version 0.6.13

* Respect the `scope` option when contructing translations

# Version 0.6.12

* Specify that the MIT license is used

# Version 0.6.12

* Fix an error creating the folder for the syncfile

# Version 0.6.11 (yanked)

* Handle sending fallbacks
* Create the schronization data file even if the containing folder is
  missing
* Fix bug where deleting a namespace and then recreating a key inside
  of it wasn't getting added.
* Normalize keys so that the scope is added to missing translations
* Throw a Localeapp::MissingApiKey exception when an API key has not
  been set

# Version 0.6.10

* Don't send the :default param with a MissingTranslation when not in
  the default locale.
* Cache MissingTranslations so that they're not sent multiple times.

# Version 0.6.9

* Make rack a dependency as we actually use it (thanks to [@martoche](https://github.com/martoche))

# Version 0.6.8

* Don't load any yaml that may contain insecure content

# Version 0.6.7

* Add rm and mv commands for deleting / renaming keys from the command line

# Version 0.6.6

* Add a timeout configuration setting

# Version 0.6.5

* Build gem with 1.8.7 to fix gemspec errors

# Version 0.6.4

* Don't send defaults if they're an array as this was causing gems that
  supply a lookup chain to be sending unwanted translations.

# Version 0.6.3

* Pulling translations now completely replaces the contents of the yaml
  files instead of selectively updating certain translations.

# Version 0.6.2

* Fix bug updating synchronization files that caused polling_interval to be ignored

# Version 0.6.1

* Fix bug where default handler was sending array rather than resolved content

# Version 0.6.0

* Support passing -k or --api-key option to commands
* Remove deprecated disabled_* configuration options
* Fix performance bug when :default specified in I18n.t call

# Version 0.5.2

* Fix bug with pulling translations changing file permissions

# Version 0.5.1

* Fix bug with encoding of response from http_client
* Test on Jruby
* Compatibility with gli 2.0.0

# Version 0.5.0

* Post translations with default values
* Change how Psych outputs yaml (for Psych versions >= 1.1.0)
* Add a --github option when installing to help setup public projects

# Version 0.4.3

* Make sure Psych is fully loaded before using it (thanks to [@tenderlove](https://github.com/tenderlove))

# Version 0.4.2

* Improve compatibility of Psych with ruby 1.9.2 (thanks to [@ardpac](https://github.com/ardpac))

# Version 0.4.1

* Ignore HUP when backgrounded. (thanks to [@xijo](https://github.com/xijo))
* Add --standalone option to install to generate a .localeapp/ config directory. This enables usage outside of rails.

# Version 0.4.0

* Use Psych to generate the yaml if it's available (This will completely change your yaml the first time you do a localeapp pull and Psych is available)
* Report when the directory to write the yml to doesn't exist (thanks to [@rmehner](https://github.com/rmehner))

# Version 0.3.2

* Use yml rather than json when making api calls to localeapp.com. This avoids symbols turning into strings and breaking parts of rails.

# Version 0.3.1

* Handle SocketError so we don't cause errors in client apps when they're not connected to the network
* Fix bug with empty log file (thanks to [@rmehner](https://github.com/rmehner))

# Version 0.3.0

* Allow symbols for environment names in config file
* `localeapp push` will now push all yaml files in a directory if it's given a directory instead of a file (thanks to [@bartlomiejdanek](https://github.com/bartlomiejdanek))
* Better daemon support. `daemon_pid_file` and `daemon_log_file` configuration options (thanks to [@bartlomiejdanek](https://github.com/bartlomiejdanek))

# Version 0.2.0

* Add `localeapp add` command for sending keys and translations from the command line
* Add `secure` configuration setting for api communications. Default: true
* Add `ssl_verify` and `ssl_ca_file` configuration settings for ssl cert verification. Off by default, see the README for more details
* Add `proxy` configuration setting

# Version 0.1.2

* Fix incorrect documentation
* Display help if unrecognized command given
* Add section on default rails translations to README

# Version 0.1.1

* Gem compiled with 1.8.7

# Version 0.1.0

* Added support for Heroku's Cedar stack
* Added a safer configuration style where enabled environments are explicitly defined
* Removed some unnecessary default options from config files generated with `localeapp install`
* Fixed `localeapp push` with no arguments
