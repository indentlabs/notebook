$(document).ready(function () {
  $('#js-content-name-filter').keyup(function (e) {
    var search_query = $(this).val();
    var content_list = $('.js-content-cards-list > .js-content-card-container');

    // Show everything, then hide what doesn't match
    content_list.hide();
    content_list.find(".js-content-name:contains(" + search_query + ")").closest('.js-content-card-container').show();
  });
});
