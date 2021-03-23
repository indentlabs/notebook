$(document).ready(function() {
  $('.autosave-closest-form-on-change').change(function () {
    console.log('autosaving');
    var content_form = $(this).closest('form');
    // content_form.submit();
    window.form_to_autosave = content_form;

    // show toast: Autosaving... / Saved.
  });

  // To ensure all fields get unblurred (and therefore autosaved) upon navigation,
  // we use this little ditty:
  window.onbeforeunload = function(e){
    $(document.activeElement).blur();
  }
});
