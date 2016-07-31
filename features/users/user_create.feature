Feature: User account creation
  As user of the site
  I want to sign up to the website
  So that, at a later date, I can access the content that I previously created

  @wip
  Scenario: A new user saves some content
    When I sign up
    And I create some content
    And I log out
    And I log in
    Then I should see the content that I created

  @wip
  Scenario: A user signs up and gets a confirmation email
    When I sign up
    Then I should get an email
