$(document).ready(function () {
  $('.panel').hide();
  $('.panel').first().show();

  $('.tab a').click(function (tab) {
    // We substring(1) here to strip the # off the beginning so we can use getElementById
    // (because we want to support slashes in category/field names, and jQuery does not).
    var target_panel_id = $(tab.target).attr('href').substring(1);
    var target_panel = $(document.getElementById(target_panel_id));

    $('.panel').hide();
    $(target_panel).show();

    // Unset the expand button's "expanded" flag, if set
    $('.expand').removeClass('expanded');

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
    if ($(this).hasClass('expanded')) {
      $(this).removeClass('expanded');

      // Reset all selected-tab styling and activate the first one
      var all_tabs = $('.content-tabs').find('li.tab a');
      all_tabs.removeClass('red-text');
      all_tabs.first().addClass('red-text');

      // Reset all panel visibility and show the first one
      var all_panels = $('.panel');
      all_panels.hide();
      all_panels.first().show();

    } else {
      $(this).addClass('expanded');
      $('.content-tabs').find('li.tab a').addClass('red-text');
      $('.panel').show();
    }
  });

  $('.new-attribute-field-link').click(function (e) {
    e.preventDefault();
    $('#attribute-field-modal').modal('open');
  });

  $('.content-tabs .tab a').first().addClass('red-text');

});

