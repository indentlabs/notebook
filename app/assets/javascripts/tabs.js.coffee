$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("." + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $([
    "general", "appearance", "social", "behavior", "history", "favorites", "relationships", "more", "abilities", "vocabulary", "speakers", "cities", "culture", "geography", "alignment", "effects", "requirements"
  ]).each (key, val) ->
    $("#show_" + val).click ->
      show_tab val