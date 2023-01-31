$(document).ready(function() {
  var recent_autosave = false;

  $('.autosave-closest-form-on-change').change(function () {
    var content_form = $(this).closest('form');

    // Submit content_form with ajax
    if (content_form) {
      // M.toast({ html: 'Saving changes...' });
      console.log('saving changes');
      recent_autosave = true;
      content_form.trigger('submit');

      setTimeout(() => recent_autosave = true, 1000);
    } else {
      console.log('error saving changes');
      // M.toast({ html: "There was an error saving your changes. Please back up any changes and refresh the page." });
    }

    // TODO: it'd be really nice to capture the response of the form submit but I don't
    // know that we can do so without ajax'ing it instead
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
