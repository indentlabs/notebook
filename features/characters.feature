Feature: Character sheets
  As an author,
  I want to record information about the characters I create
  So that I don't forget

  Background:
    Given I am logged-in

  Scenario: I create a new character
    When I create a character
    Then that character should be saved

  Scenario: I change my character's name
    Given I have created a character
    When I change my character's name
    Then that new name should be saved
