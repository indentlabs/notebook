$(document).ready(function () {
  $('.panel').hide();
  $('.panel').first().show();

  $('.tab').click(function (clicked_element) {
    var tab = $(clicked_element.target).closest('.tab a');

    // We substring(1) here to strip the # off the beginning so we can use getElementById
    // (because we want to support slashes in category/field names, and jQuery does not).
    var target_panel_id = ($(tab).attr('href') || '#').substring(1);
    var target_panel = $(document.getElementById(target_panel_id));

    $('.panel').hide();
    $(target_panel).show();

    // Unset the expand button's "expanded" flag, if set
    $('.expand').removeClass('expanded');

    setTimeout(function() {
      window.scrollTo(0, 0);
    }, 1);

    $('.content-tabs').find('.tab a.red-text').removeClass('red-text');
    $(tab).addClass('red-text');
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

    //  Hide all visible tooltips (because this doesn't trigger mouseout :( )
    $('.material-tooltip').css('visibility', 'hidden');
  });

  $('.new-attribute-field-link').click(function (e) {
    e.preventDefault();
    $('#attribute-field-modal').modal('open');
  });

  $('.content-tabs .tab a').first().addClass('red-text');

  $(document).on('click', '.favorite-button', function (evt) {
    var toggle = $(this);
    var content_id = $(this).data('content-id');
    var content_class = $(this).data('content-class');
    var current_favorite = toggle.text().trim() == 'star';

    if (current_favorite) {
      toggle.text('star_border');
      toggle.attr('data-tooltip', 'Favorite this page');

    } else {
      toggle.text('star');
      toggle.attr('data-tooltip', 'Unfavorite this page');
    }

    post_url = (content_class == 'documents' 
      ? '/documents/' + content_id + '/toggle_favorite'
      : "/plan/" + content_class + "/" + content_id + "/toggle_favorite");

    $.ajax({
      type: "POST",
      url: post_url,
      data: { id: content_id },
      success: function () {
        // console.log("success!");
      }
    });
  });

});

