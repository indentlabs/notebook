$(document).ready(function () {
  $('.content-field').find('textarea').focus(function (focus_event) {
    var focused_text_field = $(focus_event.target);
    var parent_content_field = focused_text_field.closest('.content-field');

    $('.show-when-focused').hide();
    parent_content_field.find('.show-when-focused').show();

    $('.content-field').removeClass('focused');
    parent_content_field.addClass('focused');
    $('.content-field-link-bar').hide();
    parent_content_field.find('.content-field-link-bar').show();
  });

  // um sir excuse me why does this need to be in a setTimeout? It doesn't work
  // unless it is... for whatever reason. Here be dragons.
  setTimeout(function () {
    $('.content-field').find('.chips input').focus(function (focus_event) {
      var focused_text_field = $(focus_event.target);
      var parent_content_field = focused_text_field.closest('.content-field');

      $('.show-when-focused').hide();
      parent_content_field.find('.show-when-focused').show();

      $('.content-field').removeClass('focused');
      parent_content_field.addClass('focused');
      $('.content-field-link-bar').hide();
      parent_content_field.find('.content-field-link-bar').show();
    });
  }, 100);
});
