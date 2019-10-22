$(document).ready(function () {
  $('.js-pm-show-credit-card-form').click(function () {
    $('.payment-method-form').hide();
    $('.js-pm-existing-card').show();
  });

  $('.js-pm-show-paypal-form').click(function () {
    if (!$(this).find('input').is(':disabled')) {
      $('.payment-method-form').hide();
      $('.js-pm-paypal').show();
    }
  });

  $('.card-selector').click(function () {
    var plan_id = $(this).data('plan-id');

    if (plan_id == 'monthly') {
      var form = $('.js-pm-show-paypal-form');
      
      form.find('input')
        .removeAttr('checked')
        .attr('disabled', 'disabled');

      form.removeClass('black-text').addClass('grey-text');

      $('.payment-method-form').hide();
      $('.js-pm-existing-card').show();
      $('.js-pm-show-credit-card-form').find('input')
        .attr('checked', 'checked')
        .click();

    } else {
      var form = $('.js-pm-show-paypal-form');
      
      form.find('input')
        .removeAttr('disabled');

      form.removeClass('grey-text').addClass('black-text');
    }

    $('.js-due-today').text('$' + $(this).data('plan-price'));
  });

  $('.js-pm-existing-card').show();
});