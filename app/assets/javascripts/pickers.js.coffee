$(document).ready ->
  $('.dropdown-picker li a').click ->
    val = $(this).text()
    $(this).closest('.row').find('input[type=text]').val(val)
