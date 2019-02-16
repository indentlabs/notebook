$(document).ready(function () {
  $('.js-add-tag').click(function() {
    var clicked_tag = $(this).find('.badge').data('badge-caption');

    M.Chips.getInstance($('.chips')).addChip({tag: clicked_tag});
    return false;
  });
});
