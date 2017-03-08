Feature: Unknown command

  Scenario: Reports an error when given unknown command
    When I run `localeapp foo`
    Then the exit status must be 64
    Then the output should contain:
    """
    error: Unknown command 'foo'
    """
