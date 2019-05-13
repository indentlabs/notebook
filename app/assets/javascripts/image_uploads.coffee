$ ->
  # When a user clicks to delete an image, we should remove it from the list of images after the remote request finishes
  $('a.js-remove-image[data-remote]').on 'ajax:success', (e, data, status, xhr) ->
    # Remove the image from the UI
    $(this).closest('.row').fadeOut().remove() # todo use animate.css for something more fun
    return
