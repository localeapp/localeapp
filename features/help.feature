Feature: Getting help

  Scenario: Viewing help
    In order to see what options I have
    When I run `localeapp help`
    Then the output should contain:
    """
    localeapp [global options] command [command options]
    """
