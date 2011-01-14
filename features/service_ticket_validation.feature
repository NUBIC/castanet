@wip
Feature: Service ticket validation
  To enforce user authentication in their applications
  Application developers
  Need this library to properly validate service tickets.

  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |
    And a CAS-protected application at "/app"

  Scenario: Service tickets issued by the CAS server are valid
    When a user logs into CAS as "someone" / "secret"
    And visits the application at "/app"

    Then the user should be able to access the application

  Scenario: Service tickets not issued by the CAS server are invalid
    When a user visits the application at "/app" using service ticket "ST-bad"

    Then the user should not be able to access the application
