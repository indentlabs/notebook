$(document).ready ->
  $(".location_name_generator").click ->
  target = $(this).parent().find(".text_field")
  $.ajax
    dataType: "text"
    url: "/generate/location/name"
    success: (data) ->
      target.val data

  0

  $(".character_name_generator").click ->
    target = $(this).parent().find(".text_field")
    $.ajax
      dataType: "text"
      url: "/generate/character/name"
      success: (data) ->
        target.val data

    0

  $(".character_age_generator").click ->
    target = $(this).parent().find(".text_field")
    $.ajax
      dataType: "text"
      url: "/generate/character/age"
      success: (data) ->
        target.val data

    0