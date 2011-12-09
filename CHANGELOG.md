# HEAD

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

## NOTICE

If you've added disabled_polling_environments, 
disabled_reloading_environments or disabled_sending_environments to your 
initializer you should change these to polling_environments, 
reloading_environments and sending_environments and configure as per the README
