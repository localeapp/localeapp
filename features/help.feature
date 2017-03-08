Feature: `help' command

  Scenario: Shows help when given `help' command
    When I successfully run `localeapp help`
    Then the output should contain:
    """
    localeapp [global options] command [command options]
    """
