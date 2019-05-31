$ ->
  # When a user clicks to remove a collaborator, we should remove them from the list of collaborators after the remote request finishes
  $('a.js-remove-contributor[data-remote]').on 'ajax:success', (e, data, status, xhr) ->

    # Remove the image from the UI
    $(this).closest('.collection-item').fadeOut().remove() # todo use animate.css for something more fun

    return