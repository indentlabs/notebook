$(document).ready(function () {
  // Override the :contains() selector to make it case-insensitive
  $.expr[":"].contains = $.expr.createPseudo(function(arg) {
    return function( elem ) {
      return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
    };
  });

  $('#js-content-name-filter').keyup(function (e) {
    var search_query = $(this).val();
    var content_list = $('.js-content-cards-list > .js-content-card-container');

    // Show everything, then hide what doesn't match
    content_list.hide();
    content_list.find(".js-content-name:contains(" + search_query + ")").closest('.js-content-card-container').show();
  });
});
