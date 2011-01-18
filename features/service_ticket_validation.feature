@wip
Feature: Service ticket validation
  To enforce user authentication in their applications
  Application developers
  Need this library to properly validate service tickets.

  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |

  Scenario: Service tickets issued by the CAS server are valid
    When a user logs into CAS as "someone" / "secret"
    And requests a service ticket for "https://service.example.edu"

    Then that service ticket should be valid for "https://service.example.edu"

  Scenario: Service tickets not issued by the CAS server are invalid
    When the service ticket "ST-bad" is checked for "https://service.example.edu"

    Then that service ticket should not be valid for "https://service.example.edu"
