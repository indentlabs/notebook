$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("#" + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_general").click ->
    show_tab "general"
    
  $("#show_appearance").click ->
    show_tab "appearance"
    
  $("#show_history").click ->
    show_tab "history"
    
  $("#show_abilities").click ->
    show_tab "abilities"
    
  $("#show_more").click ->
    show_tab "more"

  show_tab "general"
