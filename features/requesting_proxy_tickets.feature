Feature: Requesting proxy tickets
  Background:
    Given a proxy callback

  Scenario: A valid login should be able to request proxy tickets
    When a user logs into CAS as "right" / "right"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"

    Then that user should receive a proxy ticket

  Scenario: Proxy tickets can be used to issue proxy tickets
    Given a user logs into CAS as "right" / "right"
    And has a valid service ticket for "https://service.example.edu"
    And requests a proxy ticket for "https://proxied.example.edu"

    When that user uses their proxy ticket to request a proxy ticket for "https://another.example.edu"

    Then that user should receive a proxy ticket

  Scenario: A proxy ticket cannot be issued from a bad PGT
    Given a user logs into CAS as "right" / "right"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu" with a bad PGT

    Then the proxy ticket request should fail with "proxy ticket could not be issued"
