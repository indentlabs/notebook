$(document).ready(function () {
  $('.dark-toggle').on('click', function () {
    var toggle_icon = $(this).find('i');
    var light_mode_icon = 'brightness_high',
      dark_mode_icon = 'brightness_4';
    var dark_mode_enabled = $('body').hasClass('dark');

    window.localStorage.setItem('dark_mode_enabled', !dark_mode_enabled);
    toggle_icon.text(dark_mode_enabled ? light_mode_icon : dark_mode_icon);

    if (dark_mode_enabled) {
      $('body').removeClass('dark');
      $('html').removeClass('dark');
    } else {
      $('body').addClass('dark');
      $('html').addClass('dark');
    }

    // Update dark mode preferences server-side so we can enable it at page load 
    // and avoid any light-to-dark blinding flashes
    $.ajax({
      type: "PUT",
      dataType: "json",
      url: '/users',
      data: {
        'user': {
          'dark_mode_enabled': !dark_mode_enabled
        }
      }
    });

    // console.log('dark mode is now ' + !dark_mode_enabled);
    return false;
  });
});