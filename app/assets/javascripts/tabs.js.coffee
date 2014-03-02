$(document).ready ->
  # Define function to close all open tabs then open a specific one
  show_tab = (tab_name) ->
    $('.tab').removeClass 'active'
    $('#show_' + tab_name).parent().addClass 'active'
    $('.section').hide()
    $('.' + tab_name + '_section').css('visibility', 'visible').hide().fadeIn 'fast'

  # Define function to show content tabs
  show_content_tab = (tab_name) ->
    $('.content-section').hide()
    $('.' + tab_name + '_section').css('visibility', 'visible').hide().fadeIn 'fast'

  # Enable tab functionality on a whitelist of tab names
  list_of_valid_tabs = [
    'general', 'appearance', 'social', 'behavior', 'history', 'favorites',
    'relationships', 'settings', 'notes', 'more', 'abilities', 'speakers',
    'vocabulary', 'map', 'culture', 'cities', 'geography', 'alignment',
    'effects', 'requirements'
  ]
  list_of_valid_tabs.forEach (tab) ->
    $('#show_' + tab).click ->
      show_tab tab

  # Enable content tab functionality for whitelisted content types
  list_of_content_tabs = [
    'characters', 'equipment', 'languages', 'locations', 'magic'
  ]
  list_of_content_tabs.forEach (tab) ->
    $('#show_' + tab).click ->
      show_content_tab tab

  # Show default tab
  show_tab 'general'

  0
