Feature: `add' command

  Scenario: Adds the given translation
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add foo.baz en:"test en content" es:"test es content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """

  Scenario: Reports an error when no translation is given
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add`
    Then the output should contain:
    """
    localeapp add requires a key name and at least one translation
    """

  Scenario: Reports an error when given a translation without description
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I run `localeapp add foo.bar`
    Then the output should contain:
    """
    localeapp add requires a key name and at least one translation
    """

  Scenario: Adds the given translation when given the API key on the command line
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """

  Scenario: Adds the given translation when given the API key via environment
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I have a LOCALEAPP_API_KEY env variable set to "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """

  Scenario: Adds the given translation when given the API key in .env file
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I have a .env file containing the api key "MYAPIKEY"
    When I run `localeapp add foo.baz en:"test en content"`
    Then the output should contain:
    """
    Localeapp Add

    Sending key: foo.baz
    Success!
    """
