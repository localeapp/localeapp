Feature: Removing a translation from the command line

  Scenario: Running rm
    In order to remove an existing key
    Given I have a valid project on localeapp.com with api key "MYAPIKEY" and the translation key "foo.bar"
      And an initializer file
    When I run `localeapp rm foo.bar`
    Then the output should contain:
    """
    Localeapp rm

    Remove key: foo.bar
    Success!
    """
