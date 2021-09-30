$(document).ready(function () {
  $('.js-add-tag').click(function() {
    var clicked_tag = $(this).find('.badge').data('badge-caption');
    var chips_reference = $(this).closest('.input-field').find('.chips');

    M.Chips.getInstance(chips_reference).addChip({ tag: clicked_tag });
    return false;
  });
});
