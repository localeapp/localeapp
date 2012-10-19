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
