/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(() => // When a user clicks to remove a collaborator, we should remove them from the list of collaborators after the remote request finishes
$('a.js-remove-contributor[data-remote]').on('ajax:success', function(e, data, status, xhr) {

  // Remove the image from the UI
  $(this).closest('.collection-item').fadeOut().remove(); // todo use animate.css for something more fun

}));