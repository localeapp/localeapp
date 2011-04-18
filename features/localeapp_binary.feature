Feature: localeapp executable

  Scenario: Viewing help
    In order to see what options I have
    When I run `localeapp help`
    Then the output should contain:
    """
    Usage: localeapp COMMAND [ARGS]
    """
