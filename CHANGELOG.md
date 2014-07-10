# master

# Version 0.8.1

* Add the `blacklisted_keys_pattern` configuration option
* Prevent blacklisted keys from being sent to Locale servers in the Rails exception handler

# Version 0.8.0

* Fix problem with line ending in three dots. (@holli)
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

* Make rack a dependency as we actually use it (Thanks @martoche)

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

* Make sure Psych is fully loaded before using it (Thanks @tenderlove) 

# Version 0.4.2

* Improve compatibility of Psych with ruby 1.9.2 (Thanks @ardpac)

# Version 0.4.1

* Ignore HUP when backgrounded. (Thanks @xijo)
* Add --standalone option to install to generate a .localeapp/ config
  directory. This enables usage outside of rails.

# Version 0.4.0

* Use Psych to generate the yaml if it's available (This will completely change
  your yaml the first time you do a localeapp pull and Psych is available)
* Report when the directory to write the yml to doesn't exist (Thanks Robin
  Mehner)

# Version 0.3.2

* Use yml rather than json when making api calls to localeapp.com. This avoids
  symbols turning into strings and breaking parts of rails.

# Version 0.3.1

* Handle SocketError so we don't cause errors in client apps when they're not
  connected to the network
* Fix bug with empty log file (Thanks Robin Mehner)

# Version 0.3.0

* Allow symbols for environment names in config file
* `localeapp push` will now push all yaml files in a directory if it's given a
  directory instead of a file. (Thanks Bartłomiej Danek)
* Better daemon support. `daemon_pid_file` and `daemon_log_file` configuration
  options. (Thanks again Bartłomiej Danek)

# Version 0.2.0

* Add `localeapp add` command for sending keys and translations from the command line
* Add `secure` configuration setting for api communications. Default: true
* Add `ssl_verify` and `ssl_ca_file` configuration settings for ssl cert verification.
  Off by default, see the README for more details
* Add `proxy` configuration setting

# Version 0.1.2

* Fix incorrect documentation
* Display help if unrecognized command given
* Add section on default rails translations to README

# Version 0.1.1

* Gem compiled with 1.8.7

# Version 0.1.0

* Added support for Heroku's Cedar stack
* Added a safer configuration style where enabled environments are explicitly
  defined
* Removed some unnecessary default options from config files generated with 
  `localeapp install`
* Fixed `localeapp push` with no arguments
