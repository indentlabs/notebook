$(document).ready ->

  # Enable clicking an image to upload a map
  $('#placeholder_map_input').on 'click', (e) ->
    e.preventDefault()
    $('#location_map').trigger 'click'
    $('#location_map').removeClass 'hidden'
