$(document).ready(function() {
  $('.autosave-closest-form-on-change').change(function () {
    var content_form = $(this).closest('form');

    if (content_form) {
      M.toast({ html: 'Saving your changes...' });

      var form_data = content_form.serialize();
      form_data += "&authenticity_token=" + $('meta[name="csrf-token"]').attr('content');

      $.ajax({
        url:  content_form.attr('action'),
        type: content_form.attr('method').toUpperCase(),
        data: form_data,
        success: function(response) {
          M.toast({ html: 'Saved successfully!' });
        },
        error: function(response) {
          M.toast({ html: "There was an error saving your changes. Please back up any changes and refresh the page." });
        }
      });
    } else {
      M.toast({ html: "There was an error saving your changes. Please back up any changes and refresh the page." });
    }
  });

  $('.submit-closest-form-on-click').on('click', function() {
    $(this).closest('form').submit();
  })

  // To ensure all fields get unblurred (and therefore autosaved) upon navigation,
  // we use this little ditty:
  window.onbeforeunload = function(e){
    $(document.activeElement).blur();
  }
});
