Feature: Renaming a translation from the command line

  Scenario: Running mv
    In order to rename an existing key
    Given I have a valid project on localeapp.com with api key "MYAPIKEY" and the translation key "foo.bar"
      And an initializer file
    When I run `localeapp mv foo.bar foo.baz`
    Then the output should contain:
    """
    Localeapp mv

    Renaming key: foo.bar to foo.baz
    Success!
    """

