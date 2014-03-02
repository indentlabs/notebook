$(document).ready ->
  $('.dropdown-picker li a').click ->
    val = $(this).text()
    $(this).closest('.controls').find('input').val(val)
