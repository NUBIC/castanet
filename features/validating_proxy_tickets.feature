Feature: Validating proxy tickets
  To enforce user authentication in their applications
  Application developers
  Need this library to validate proxy tickets.

  Background:
    And a proxy callback
  
  Scenario: Proxy tickets issued via a valid PGT are valid
    Given a user logs into CAS as "someone" / "secret"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"
    And that proxy ticket is checked for "https://proxied.example.edu"

    Then that proxy ticket should be valid

  Scenario: Proxy tickets not issued by the CAS server are invalid
    When the proxy ticket "PT-bad" is checked for "https://service.example.edu"

    Then that proxy ticket should not be valid

  Scenario: Previously used proxy tickets are invalid
    Given a user logs into CAS as "someone" / "secret"
    And has a valid service ticket for "https://service.example.edu"
    And requests a proxy ticket for "https://proxied.example.edu"

    When that proxy ticket is checked for "https://proxied.example.edu"
    And that proxy ticket is checked again for "https://proxied.example.edu"

    Then that proxy ticket should not be valid
