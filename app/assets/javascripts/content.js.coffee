$(document).ready ->
  $('.tab').click ->
    $('.panel').hide()
    if $('.card-action a').attr('href')
      btn_href = $('.card-action a').attr('href').split('#')[0];
      tab_anchor = $(this).find('a').attr('href')
      $('.card-action a').attr('href', btn_href + tab_anchor);

  if location.hash?
    setTimeout ( ->
      window.scrollTo(0, 0);
    ), 1

  $('.modal').modal();

  $('.new-attribute-field-link').click (e) ->
    e.preventDefault()
    $("#attribute-field-modal").modal('open')

  $('.share').click ->
    $('#share-modal').modal('open')

  $('.expand').click ->
    $('.tabs li').first().find('a').click()
    $('.panel').show()