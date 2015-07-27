Feature: JSON format support

  Background:
    Given I have a valid project on localeapp.com with api key "MYAPIKEY"
    And I have translations on localeapp.com for the project with api key "MYAPIKEY"
    And a directory named "config/locales"
    And a directory named "log"
    And an initializer file with:
      """
      require "localeapp/rails"

      Localeapp.configure do |config|
        config.api_key  = "MYAPIKEY"
        config.format   = :json
      end

      """

  Scenario: creates JSON translation files
    When I pull all translations
    Then locale files with ".json" suffix must exist

  Scenario: pulls valid JSON translations
    When I pull all translations
    Then JSON locale files must include my translations

  Scenario: pushes given JSON translations file to the API
    Given a JSON translations file for locale "en"
    When I push JSON translations file for locale "en"
    Then the output must match /pushing.+en\.json.+success/mi

  Scenario: pushes globbed JSON translations files to the API
    Given a JSON translations file for locale "en"
    When I push all translations
    Then the output must match /pushing.+en\.json.+success/mi
