$(document).ready(function() {
  var recent_autosave = false;

  $('.autosave-closest-form-on-change').change(function () {
    var content_form = $(this).closest('form');

    // Submit content_form with ajax
    if (content_form) {
      // M.toast({ html: 'Saving your changes...' });

      recent_autosave = true;
      setTimeout(() => recent_autosave = false, 1000);

      var form_data = content_form.serialize();
      form_data += "&authenticity_token=" + encodeURIComponent($('meta[name="csrf-token"]').attr('content'));

      $.ajax({
        url:  content_form.attr('action') + '.json',
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
      console.log('error saving changes');
      // M.toast({ html: "There was an error saving your changes. Please back up any changes and refresh the page." });
    }
  });

  $('.submit-closest-form-on-click').on('click', function() {
    $(this).closest('form').submit();
  })

  // To ensure all fields get unblurred (and therefore autosaved) upon navigation,
  // we use this little ditty:
  window.onbeforeunload = function(e){
    if (!recent_autosave) {
      $(document.activeElement).blur();
    }
  }
});
