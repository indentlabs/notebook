Feature: Character sheets
  As an author,
  I want to record information about the content I create
  So that I don't forget

  Background:
    Given I am logged-in

  Scenario Outline: I create new content
    When I create a <content_type>
    Then that <content_type> should be saved

    Examples:
      | content_type |
      | character    |
      | location     |
      | item         |
      | universe     |

  Scenario Outline: I change my content's name
    Given I have created a <content_type>
    When I change my <content_type>'s name
    Then that new name should be saved

    Examples:
      | content_type |
      | character    |
      | location     |
      | item         |
      | universe     |
