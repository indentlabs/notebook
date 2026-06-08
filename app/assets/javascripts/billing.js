$(document).ready(function () {
  $('.js-prepaid-promo-code').click(function (event) {
    var code = $(event.target).text();
    $('#promotional_code_promo_code').val(code);
    return false;
  });

  // Prevent accidental double plan changes: once a plan-change link is clicked, disable it so a
  // slow/laggy page can't trigger the change twice. The server is also protected against this;
  // this is just a first line of defense for UX.
  $('.js-plan-change').click(function (event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('disabled')) {
      return;
    }
    if ($link.data('clicked')) {
      event.preventDefault();
      return false;
    }
    $link.data('clicked', true);
    $link.addClass('disabled').text('Processing...');
  });
})