$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("." + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_general").click ->
    show_tab "general"
    
  $("#show_appearance").click ->
    show_tab "appearance"
    
  $("#show_alignment").click ->
    show_tab "alignment"
    
  $("#show_effects").click ->
    show_tab "effects"
    
  $("#show_more").click ->
    show_tab "more"

  show_tab "general"
