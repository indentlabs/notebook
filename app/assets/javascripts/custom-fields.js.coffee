$(document).ready ->
  $(".custom-field-form").fadeOut 1

  $(".toggle-custom-fields").click (v) ->
    $(this).siblings(".custom-field-form").toggle "slow"

  $(".add-custom-field").click (v) ->
    cloneable = $(this).siblings(".control-group").first()
    cloneable.clone().hide().appendTo($(this).parent()).fadeIn "slow"

  $(".remove-custom-field").live 'click', ->
    $(this).closest(".control-group").fadeOut("slow")