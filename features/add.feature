Feature: `add' command

  Scenario: Adds the given translation
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And an initializer file
    When I successfully run `localeapp add foo.baz en:"test en content" es:"test es content"`
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
    Then the exit status must be 1
    And the output should contain:
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

  Scenario: Reports an error when the given API key is incorrect
    Given no project exist on localeapp.com with API key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY add foo en:bar`
    Then the exit status must be 70
    And the output must match /error.+404/i
