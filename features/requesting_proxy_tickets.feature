@wip
Feature: Requesting proxy tickets
  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |
    And a proxy callback

  Scenario: A valid login should be able to request proxy tickets
    Given a user logs into CAS as "someone" / "secret"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"

    Then that proxy ticket should be valid for "https://proxied.example.edu"
