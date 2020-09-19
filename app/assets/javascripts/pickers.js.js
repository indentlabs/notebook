/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(document).ready(() => $('.dropdown-picker li a').click(function() {
  const val = $(this).text();
  return $(this).closest('.row').find('input[type=text]').val(val);
}));
