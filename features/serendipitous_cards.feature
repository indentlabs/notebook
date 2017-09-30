Feature: Serendipitous cards

  Scenario: I update character info using a serendipitous card
    Given I am logged-in
    And I create a character
    When I view the dashboard
    Then I should see my dashboard
    And I answer the Serendipitous question
    Then that new field should be saved
