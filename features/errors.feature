Feature: Errors handling

  Scenario: Reports an error when the given API key is incorrect
    Given no project exist on localeapp.com with API key "MYAPIKEY"
    When I run `localeapp -k MYAPIKEY add foo en:bar`
    Then the exit status must be 70
    And the output must match /error.+404/i

  # FIXME: we should have only *one* test for this, result should not differ
  # depending on the command. If we don't fix/refactor this, then it means we
  # should test/handle and maybe fix error handling for *all* commands in their
  # respective feature file.
  # Scenario: Reports an error when the given API key is incorrect
  #   Given no project exist on localeapp.com with API key "MYAPIKEY"
  #   When I run `localeapp -k MYAPIKEY pull`
  #   Then the exit status must be 70
  #   And the output must match /error.+404/i
