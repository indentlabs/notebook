$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("." + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_general").click ->
    show_tab "general"
    
  $("#show_culture").click ->
    show_tab "culture"
    
  $("#show_cities").click ->
    show_tab "cities"
    
  $("#show_geography").click ->
    show_tab "geography"
    
  $("#show_history").click ->
    show_tab "history"
    
  $("#show_more").click ->
    show_tab "more"

  show_tab "general"
