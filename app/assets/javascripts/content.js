$(document).ready(function () {
  $('.panel').hide();
  $('.panel').first().show();

  $('.tab a').click(function (tab) {
    var target_panel = $(tab.target).attr('href');

    $('.panel').hide();
    $(target_panel).show();

    setTimeout(function() {
      window.scrollTo(0, 0);
    }, 1);

    $(tab.target).closest('.content-tabs').find('.tab a').removeClass('red-text');
    $(tab.target).addClass('red-text');
  });

  $('.modal').modal();

  $('.share').click(function () {
    $('#share-modal').modal('open');
  });

  $('.expand').click(function () {
    $('.content-tabs').find('li.tab a').addClass('red-text');
    $('.panel').show();
  });

  $('.new-attribute-field-link').click(function (e) {
    e.preventDefault();
    $('#attribute-field-modal').modal('open');
  });

});

