Feature: localeapp executable
  Scenario: Running a command that doesn't exist
    In order to warn of a bad command
    When I run `localeapp foo`
    Then the output should contain:
    """
    error: Unknown command 'foo'
    """
