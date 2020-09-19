Notebook.StripeHandler = class StripeHandler {
  constructor(el) {
    this.el = el;
    if (!(this.el.length > 0)) { return; }

    let $form = $('#payment-form');
    const stripeResponseHandler = function(status, response) {
      $form = $('#payment-form');
      if (response.error) {
        // Show the errors on the form:
        $form.find('.payment-errors').text(response.error.message);
        $form.find('.submit').prop('disabled', false);

      } else {
        // Insert the created token ID into the form so it gets submitted to the server:
        const token = response.id;
        $form.append($('<input type="hidden" name="stripeToken">').val(token));

        // Submit the form:
        $form.get(0).submit();
      }

    };

    $form.submit(function(event) {
      // Disable the submit button to prevent repeated clicks:
      $form.find('.submit').prop('disabled', true);

      // Request a token from Stripe:
      Stripe.card.createToken($form, stripeResponseHandler);

      // Prevent the form from being submitted:
      return false;
    });

  }
};

$(() => new Notebook.StripeHandler($("body.subscriptions.information")));
