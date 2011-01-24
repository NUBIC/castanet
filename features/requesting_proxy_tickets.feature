Feature: Requesting proxy tickets
  Background:
    Given the CAS server accepts the credentials
      | username | password |
      | someone  | secret   |

  Scenario: A valid login should be able to request proxy tickets
    Given a proxy callback
    And a user logs into CAS as "someone" / "secret"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"

    Then that proxy ticket should be valid

  Scenario: A proxy ticket cannot be issued if a proxy callback is not present
    Given a user logs into CAS as "someone" / "secret"
    And a valid service ticket for "https://service.example.edu"

    When that user requests a proxy ticket for "https://proxied.example.edu"

    Then the proxy ticket request should fail with "proxy_retrieval_url is invalid"
