$(document).ready(function () {
  $('.card-selector-group .card-selector').click(function (e) {
    // Scope up to .card-selector since DOM elements within .card-selector can hijack events
    var selected_card = $(e.target).closest('.card-selector').first();
    var card_group    = selected_card.closest('.card-selector-group');

    // Reset all selected cards
    card_group.find('.card-selector').removeClass('active');

    // Select the targeted card
    selected_card.addClass('active');

    console.log(selected_card);
  });

  
});