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