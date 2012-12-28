$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("." + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_general").click ->
    show_tab "general"
    
  $("#show_vocabulary").click ->
    show_tab "vocabulary"
    
  $("#show_history").click ->
    show_tab "history"
    
  $("#show_speakers").click ->
    show_tab "speakers"
    
  $("#show_more").click ->
    show_tab "more"

  show_tab "general"
