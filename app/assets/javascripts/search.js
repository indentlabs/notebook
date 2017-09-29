$(function () {
  $('a[href="#search"]').on('click', function(event) {
    event.preventDefault();
    $('#search').addClass('open');
    $('#search > form > input[type="search"]').focus();
  });

  $('#search, #search button.close').on('click keyup', function(event) {
    if (event.target == this || event.target.className == 'close red' || event.keyCode == 27) {
      $(this).removeClass('open');
    }
  });
});