$(document).ready ->
  show_tab = (tab_name) ->
    $(".tab").removeClass "active"
    $("#show_" + tab_name).parent().addClass "active"
    $(".section").hide()
    $("#" + tab_name + "_section").css("visibility", "visible").hide().fadeIn "fast"

  $("#show_appearance").click ->
    show_tab "appearance"

  $("#show_social").click ->
    show_tab "social"

  $("#show_behavior").click ->
    show_tab "behavior"

  $("#show_history").click ->
    show_tab "history"

  $("#show_favorites").click ->
    show_tab "favorites"

  $("#show_relationships").click ->
    show_tab "relationships"

  $("#show_more").click ->
    show_tab "more"

  show_tab "appearance"

