$(document).ready(function() {
  $('.autosave-closest-form-on-change').change(function () {
    console.log('autosaving');
    var content_form = $(this).closest('form');

    M.toast({ html: 'Saving changes...' });
    content_form.submit();

    // show toast: Autosaving... / Saved.
  });

  // To ensure all fields get unblurred (and therefore autosaved) upon navigation,
  // we use this little ditty:
  window.onbeforeunload = function(e){
    $(document.activeElement).blur();
  }
});
