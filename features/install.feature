Feature: `install' command

  Scenario: Installs rails configuration
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I successfully run `localeapp install MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And a file named "config/initializers/localeapp.rb" should exist

  Scenario: Installs standalone configuration when given --standalone option
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I successfully run `localeapp install --standalone MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    NOTICE: you probably want to add .localeapp to your .gitignore file
    Writing configuration file to .localeapp/config.rb
    WARNING: please create the locales directory. Your translation data will be stored there.
    """
    And a file named ".localeapp/config.rb" should exist

  Scenario: Installs standalone config and other files when given --github option
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I successfully run `localeapp install --github MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    NOTICE: you probably want to add .localeapp to your .gitignore file
    Writing configuration file to .localeapp/config.rb
    """
    And a file named ".localeapp/config.rb" should exist
    And a file named ".gitignore" should exist
    And a file named "README.md" should exist

  Scenario: Installs heroku config files when given --heroku option
    Given I have a valid heroku project
    When I successfully run `localeapp install --heroku`
    Then the output should contain:
    """
    Localeapp Install

    Getting API key from heroku config
    Add the following line to your .env file for Foreman
    LOCALEAPP_API_KEY=MYAPIKEY
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And a file named "config/initializers/localeapp.rb" should exist
    And the file "config/initializers/localeapp.rb" should contain "config.api_key = ENV['LOCALEAPP_API_KEY']"

  Scenario: Reports an error when given incorrect API key
    Given I have a valid project on localeapp.com but an incorrect api key "BADAPIKEY"
    When I run `localeapp install BADAPIKEY`
    Then the exit status must be 1
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: BADAPIKEY
    ERROR: Project not found
    """
    And a file named "config/initializers/localeapp.rb" should not exist
