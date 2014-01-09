$(document).ready ->
  show_content_tab = (tab_name) ->
    $(".content-section").hide()
    $("." + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_characters").click ->
    show_content_tab "characters"
  
  $("#show_equipment").click ->
    show_content_tab "equipment"
  
  $("#show_languages").click ->
    show_content_tab "languages"
  
  $("#show_locations").click ->
    show_content_tab "locations"
  
  $("#show_magic").click ->
    show_content_tab "magic"
  
    0
