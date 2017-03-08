Feature: `rm' command

  Scenario: Removes the given key
    Given I have a valid project on localeapp.com with api key "MYAPIKEY" and the translation key "foo.bar"
    And an initializer file
    When I successfully run `localeapp rm foo.bar`
    Then the output should contain:
    """
    Localeapp rm

    Remove key: foo.bar
    Success!
    """

  Scenario: Reports an error when the given API key is incorrect
    Given no project exist on localeapp.com with API key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY rm foo.bar`
    Then the exit status must be 70
    And the output must match /error.+404/i
