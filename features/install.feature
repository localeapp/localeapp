Feature: Installation

  Scenario: Running Rails install
    In order to configure my project and check my api key is correct
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I run `localeapp install MYAPIKEY`
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
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I run `localeapp install --standalone MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And help should not be displayed
    And a file named ".localeapp/config.rb" should exist
    And the exit status should be 0

  Scenario: Running github install
    In order to configure my public github project and check my api key is correct
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I run `localeapp install --github MYAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And help should not be displayed
    And a file named ".localeapp/config.rb" should exist
    And a file named ".gitignore" should exist
    And a file named "README.md" should exist
    And the exit status should be 0

  Scenario: Running heroku install with no api key
    In order to configure my project to use localeapp as a heroku addon
    When I have a valid heroku project
    And I run `localeapp install --heroku`
    Then the output should contain:
    """
    Localeapp Install

    Getting API key from heroku config
    API Key: MYAPIKEY
    Checking API key: MYAPIKEY
    Success!
    Project: Test Project
    Default Locale: en (English)
    """
    And help should not be displayed
    And a file named "config/initializers/localeapp.rb" should exist
    And the exit status should be 0

  Scenario: Running install with bad api key
    In order to configure my project and check my api key is correct
    When I have a valid project on localeapp.com but an incorrect api key "BADAPIKEY"
    And I run `localeapp install BADAPIKEY`
    Then the output should contain:
    """
    Localeapp Install

    Checking API key: BADAPIKEY
    ERROR: Project not found
    """
    And help should not be displayed
    And a file named "config/initializers/localeapp.rb" should not exist
    And the exit status should not be 0
