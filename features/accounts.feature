Feature: User accounts

  Scenario: I sign up
    When I sign up
    Then I should see my dashboard

  Scenario: I log in as an existing user
    Given I have an account
    When I log in
    Then I should see my dashboard

  Scenario: I log out, and then log in
    When I sign up
    Then I log out
    Then I log in
    Then I should see my dashboard
