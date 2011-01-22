@wip
Feature: Requesting proxy tickets
  To request access to an application on a user's behalf
  Application developers
  Need this library to request proxy tickets.

  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |
    And CAS proxying is enabled

  Scenario: The client can request proxy tickets
    When a user logs into CAS as "someone" / "secret"
