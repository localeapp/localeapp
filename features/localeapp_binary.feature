Feature: localeapp executable

  Scenario: Viewing help
    In order to see what options I have
    When I run `localeapp help`
    Then the output should contain:
    """
    Usage: localeapp COMMAND [ARGS]

    Commands:
      install <key> - Creates new configuration files and confirms key works
    """

  Scenario: Running install
    In order to configure my project and check my api key is correct
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I run `localeapp install MYAPIKEY`
    Then the output should contain:
    """
    LocaleApp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And a file named "config/initializers/locale_app.rb" should exist
