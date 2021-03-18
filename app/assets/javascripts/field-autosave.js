$(document).ready(function() {
  $('.panel-field.autosave-field').click(function () {
    console.log('autosaving');
    var content_form = $(this).closest('form');
    content_form.submit();
  });

  // To ensure all fields get unblurred (and therefore autosaved) upon navigation,
  // we use this little ditty:
  window.onbeforeunload = function(e){
    $(document.activeElement).blur();
  }
});
