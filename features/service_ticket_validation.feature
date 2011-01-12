@wip
Feature: Service ticket validation
  To enforce user authentication in their applications
  Application developers
  Need this library to properly validate service tickets.

  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |
    And a CAS-protected application named "app"

  Scenario: Service tickets issued by the CAS server are valid
    Given I log in to "app" as "someone" / "secret"

    When I get a service ticket from the CAS server
    And I validate that service ticket

    Then that service ticket should be valid

  Scenario: Replayed service tickets are invalid
    Given I log in to "app" as "someone" / "secret"

    When I get a service ticket from the CAS server
    And I validate that service ticket
    And I validate that service ticket again

    Then that service ticket should not be valid

  Scenario: Service tickets not issued by the CAS server are invalid
    When I validate the service ticket "ST-bad"

    Then that service ticket should not be valid
