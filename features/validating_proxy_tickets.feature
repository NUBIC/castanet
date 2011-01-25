Feature: Validating proxy tickets
  To enforce user authentication in their applications
  Application developers
  Need this library to validate proxy tickets.

  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |
    And a proxy callback
  
  Scenario: Proxy tickets issued via a valid PGT are valid
    Given a user logs into CAS as "someone" / "secret"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"

    Then that proxy ticket should be valid for "https://proxied.example.edu"

  @wip
  Scenario: Proxy tickets not issued via a valid PGT are invalid

  @wip
  Scenario: Previously used proxy tickets are invalid
