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
  
  $(".dropdown-picker li a").click ->
    val = $(this).text()
    $(this).closest('.controls').find('input').val(val)

  show_tab "general"

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
