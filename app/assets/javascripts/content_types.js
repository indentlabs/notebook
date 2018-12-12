$(document).ready(function() {
  $('.js-enable-content-type').click(function () {
    var content_type = $(this).data('content-type');
    var related_card = $(this).children('.card').first();
    var is_currently_active = related_card.hasClass('active');

    $.post('/customization/toggle_content_type', {
      content_type: content_type,
      active: is_currently_active ? 'off' : 'on'
    });

    if (is_currently_active) {
      related_card.removeClass('active');
    } else {
      related_card.addClass('active');
    }

    // Return false so we don't jump to the top of the page on link click
    return false;
  });
});
