$(document).ready(function () {
  $('.js-show-category-suggestions').click(function () {
    var content_type = $(this).closest('.attributes-editor').data('content-type');
    var result_container = $(this).siblings(".suggest-categories-container").first();
    
    $.ajax({
      dataType: "json",
      url: "/api/v1/categories/suggest/" + content_type,
      success: function (data) {
        var existing_categories = $('.js-category-label').map(function(){
          return $.trim($(this).text());
        }).get();

        var new_categories = data.filter(c => !existing_categories.includes(c));
        var any_suggestions = new_categories.length > 0;
        if (any_suggestions) {
          result_container.html('');
          $.each(new_categories, function(i, value) {
            result_container.append(
              $('<a />')
                .attr('href', '#')
                .addClass('category-suggestion-link chip hoverable')
                .text(value)
                .on('click', function () {
                  $('.js-category-input').text($(this).text());
                  $('.js-category-input').siblings('label').addClass('active');
                  return false;
                })
            );
          });
        } else {
          result_container.text("It doesn't look like there are any suggestions right now. Since suggestions are constantly growing, check back later and there might be more!");
        }
      }
    });

    $(this).hide();
    return false;
  });
});