$(document).ready(function() {
  $('.autosave-closest-form-on-change').change(function () {
    var content_form = $(this).closest('form');

    if (content_form) {
      M.toast({ html: 'Saving changes...' });
      content_form.submit();
    } else {
      M.toast({ html: "There was an error saving your changes. Please back up any changes and refresh the page." });
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
    $(document.activeElement).blur();
  }
});
