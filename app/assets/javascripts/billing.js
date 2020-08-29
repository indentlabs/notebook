$(document).ready(function () {
  $('.js-prepaid-promo-code').click(function (event) {
    var code = $(event.target).text();
    $('#promotional_code_promo_code').val(code);
    return false;
  });
})