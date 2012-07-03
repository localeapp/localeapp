Feature: localeapp executable

  Scenario: Viewing help
    In order to see what options I have
    When I run `localeapp help`
    Then the output should contain:
    """
    usage: localeapp [global options] command [command options]
    """

  Scenario: Running a command that doesn't exist
    In order to warn of a bad command
    When I run `localeapp foo`
    Then the output should contain:
    """
    error: Unknown command 'foo'. Use 'localeapp help' for a list of commands
    """

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

  Scenario: Running add
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add foo.baz en:"test en content" es:"test es content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """

  Scenario: Running add with no arguments
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add`
    Then the output should contain:
    """
    localeapp add requires a key name and at least one translation
    """

  Scenario: Running add with just a key name
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add foo.bar`
    Then the output should contain:
    """
    localeapp add requires a key name and at least one translation
    """

  Scenario: Running pull
    In order to retreive my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    And a directory named "config/locales"
    When I run `localeapp pull`
    Then the output should contain:
    """
    Localeapp Pull

    Fetching translations:
    Success!
    Updating backend:
    Success!
    """
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist

  Scenario: Running pull without having a locales dir
    In order to retreive my translations
    Given I have a translations on localeapp.com for the project with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp pull`
    Then the output should contain:
    """
    Could not write locale file, please make sure that config/locales exists and is writeable
    """

  Scenario: Running push on a file
    In order to send my translations
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And an empty file named "config/locales/en.yml"
    When I run `localeapp push config/locales/en.yml`
    Then the output should contain:
    """
    Localeapp Push

    Pushing file en.yml:
    Success!

    config/locales/en.yml queued for processing.
    """
    And help should not be displayed

  Scenario: Running push on a directory
    In order to send my translations
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And an empty file named "config/locales/en.yml"
    And an empty file named "config/locales/es.yml"
    When I run `localeapp push config/locales`
    Then the output should contain:
    """
    Localeapp Push

    Pushing file en.yml:
    Success!

    config/locales/en.yml queued for processing.

    Pushing file es.yml:
    Success!

    config/locales/es.yml queued for processing.
    """
    And help should not be displayed

  Scenario: Running update
    In order to receive the translations that have been updated since the last check
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    And a file named "log/localeapp.yml" with:
    """
    ---
    :updated_at: 120
    :polled_at: 130
    """
    And new translations for the api key "MYAPIKEY" since "120" with time "140"
    And a directory named "config/locales"
    When I run `localeapp update`
    Then the output should contain:
    """
    Localeapp update: checking for translations since 120
    Found and updated new translations
    """
    And help should not be displayed
    And a file named "config/locales/en.yml" should exist
    # check the content here
    # and the localeapp.yml file
