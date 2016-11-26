Feature: Installation

  Scenario: Running Rails install
    In order to configure my project and check my api key is correct
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp install MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And help should not be displayed
    And a file named "config/initializers/localeapp.rb" should exist
    And the exit status should be 0

  Scenario: Running standalone install
    In order to configure my non rails project and check my api key is correct
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp install --standalone MYAPIKEY`
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
    And help should not be displayed
    And a file named ".localeapp/config.rb" should exist
    And the exit status should be 0

  Scenario: Running github install
    In order to configure my public github project and check my api key is correct
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp install --github MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    NOTICE: you probably want to add .localeapp to your .gitignore file
    Writing configuration file to .localeapp/config.rb
    """
    And help should not be displayed
    And a file named ".localeapp/config.rb" should exist
    And a file named ".gitignore" should exist
    And a file named "README.md" should exist
    And the exit status should be 0

  Scenario: Running heroku install with no api key
    In order to configure my project to use localeapp as a heroku addon
    Given I have a valid heroku project
    When I run `localeapp install --heroku`
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
    And help should not be displayed
    And a file named "config/initializers/localeapp.rb" should exist
    And the file "config/initializers/localeapp.rb" should contain "config.api_key = ENV['LOCALEAPP_API_KEY']"
    And the exit status should be 0

  Scenario: Saving api key in .env
    In order to configure my non rails project and have an api key saved in the .env file
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I successfully run `localeapp install --standalone MYAPIKEY --dotenv`
    Then the output should contain "NOTICE: API key saved to .env"
    And a file named ".env" should contain "LOCALEAPP_API_KEY=MYAPIKEY"

  Scenario: Running install with bad api key
    In order to configure my project and check my api key is correct
    Given I have a valid project on localeapp.com but an incorrect api key "BADAPIKEY"
    When I run `localeapp install BADAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: BADAPIKEY
    ERROR: Project not found
    """
    And help should not be displayed
    And a file named "config/initializers/localeapp.rb" should not exist
    And the exit status should not be 0
