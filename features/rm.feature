Feature: `rm' command

  Scenario: Removes the given key
    Given I have a valid project on localeapp.com with api key "MYAPIKEY" and the translation key "foo.bar"
    And an initializer file
    When I run `localeapp rm foo.bar`
    Then the output should contain:
    """
    Localeapp rm

    Remove key: foo.bar
    Success!
    """
