Feature: Adding a translation from the command line

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

  Scenario: Running add with no initializer file, passing the key on the command line
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """

  Scenario: Running add with no initializer file, passing the key via an ENV variable
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I have a LOCALEAPP_API_KEY env variable set to "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """
    Then I clear the LOCALEAPP_API_KEY env variable

  Scenario: Running add with no initializer file, passing the key via a .env file
    In order to add a key and translation content
    When I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I have a .env file containing the api key "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """
