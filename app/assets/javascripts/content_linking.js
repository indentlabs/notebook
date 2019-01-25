$(document).ready(function () {
  function add_link_bar(link_bar_container) {
    $('.content-field-link-bar-container').html('');
    $(link_bar_container).html($('#content-field-link-bar-template').html())
    $(link_bar_container).find('.content-field-link-bar').show();
    $(link_bar_container).find('.dropdown-trigger').dropdown({coverTrigger: false});
    $(link_bar_container).find('.tooltipped').tooltip({ enterDelay: 50 });
    add_link_bar_click_handlers();
  }

  $('.content-field').find('textarea').focus(function (focus_event) {
    var focused_text_field = $(focus_event.target);
    var parent_content_field = focused_text_field.closest('.content-field');

    $('.content-field').removeClass('focused');
    parent_content_field.addClass('focused');
    $('.content-field-link-bar').hide();
    parent_content_field.find('.content-field-link-bar').show();

    add_link_bar(parent_content_field.find('.content-field-link-bar-container'));
  });

  function add_link_bar_click_handlers() {
    $('.js-content-link-option').click(function (click_event) {
      var selected_option    = $(click_event.target);
      var textarea_to_modify = selected_option
                                 .closest('.content-field')
                                 .find('textarea');
      var current_textarea_value = textarea_to_modify.val();

      var token_to_insert = [
        '[[',
        selected_option.data('content-type'),
        '-',
        selected_option.data('content-id'),
        ']]'
      ].join('')

      // If the final character of the textarea is a newline or a space
      // character, then we want to just append our token. Otherwise, we want
      // to prepend our token with a space so it is properly separated.
      var final_letter_presently = current_textarea_value.slice(-1);
      if (final_letter_presently != ' ' && final_letter_presently != "\n") {
        // Prepend a space
        token_to_insert = ' ' + token_to_insert;
      }

      // Make the change!
      textarea_to_modify.val(current_textarea_value + token_to_insert);

      // Don't jump to the top of the page after clicking!
      click_event.stopPropagation();
      return false;
    });

    $('div.btn-group.with-toggler > a.btn:first').click(function () {
      var group_is_open = $('div.btn-group.with-toggler > a.btn:nth-child(2)').is(':visible');
      var rest_of_group = $('div.btn-group.with-toggler > a:not(:first-child)');
      var applied_class = group_is_open ? 'fadeOutLeft' : 'fadeInLeft';

      if (group_is_open) {
        rest_of_group.fadeOut();
      } else {
        rest_of_group.fadeIn();
      }
    });
  }
});
