$(document).ready(function() {
  var recent_autosave = false;

  $('.autosave-closest-form-on-change').change(function () {
    var content_form = $(this).closest('form');

    var default_border_class     = 'border-gray-200'; // This needs to match whatever the actual CSS on the element is!
    var in_progress_saving_class = 'border-yellow-400';
    var saved_successfully_class = 'border-green-400';
    var error_saving_class       = 'border-red-400';

    // Submit content_form with ajax
    if (content_form) {
      recent_autosave = true;
      setTimeout(() => recent_autosave = false, 1000);

      var form_data = content_form.serialize();
      form_data += "&authenticity_token=" + encodeURIComponent($('meta[name="csrf-token"]').attr('content'));

      var field = $(this);

      console.log('wip saving');
      field.removeClass(default_border_class);
      field.addClass(in_progress_saving_class);
      $.ajax({
        url:  content_form.attr('action') + '.json',
        type: content_form.attr('method').toUpperCase(),
        data: form_data,
        success: function(response) {
          console.log('saved ok');
          field.removeClass(in_progress_saving_class);
          field.addClass(saved_successfully_class);

          // Reset back to default coloring after 10 seconds
          setTimeout(function () {
            field.removeClass(saved_successfully_class);
            field.addClass(default_border_class);
          }, 10000);
        },
        error: function(response) {
          console.log('error saving');
          field.removeClass(in_progress_saving_class);
          field.addClass(error_saving_class);

          // TODO show some modal or something
        }
      });
    } else {
      console.log('error saving changes');

      // TODO show some message to refresh the page or something
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
