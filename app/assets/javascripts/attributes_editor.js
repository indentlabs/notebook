$(document).ready(function () {
  $('.js-show-category-suggestions').click(function () {
    var content_type     = $(this).closest('.attributes-editor').data('content-type');
    var result_container = $(this).siblings(".suggest-categories-container").first();
    
    $.ajax({
      dataType: "json",
      url: "/plan/attribute_categories/suggest?content_type=" + content_type,
      success: function (data) {
        console.log('Categories suggestion data received:', data);
        console.log('Data type:', typeof data);
        console.log('Is array:', Array.isArray(data));
        
        // If data is a string, try to parse it as JSON
        if (typeof data === 'string') {
          try {
            data = JSON.parse(data);
            console.log('Parsed data:', data);
          } catch (e) {
            console.error('Failed to parse JSON:', e);
            return;
          }
        }
        
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
          result_container.text("It doesn't look like there are any suggestions right now. Since our suggestions are constantly growing, check back later and there might be more!");
        }
      }
    });

    $(this).hide();
    return false;
  });

  $('.js-show-field-suggestions').click(function () {
    var content_type     = $(this).closest('.attributes-editor').data('content-type');
    var category_label   = $(this).closest('.js-category-container').find('.js-category-label').text().trim();
    var result_container = $(this).siblings('.suggest-fields-container').first();

    $.ajax({
      dataType: "json",
      url: "/plan/attribute_fields/suggest?content_type=" + content_type + "&category=" + category_label,
      success: function (data) {
        // console.log("new fields");
        // console.log(data);

        var existing_fields = result_container.closest('.js-category-container').find('.js-field-label').map(function(){
          return $.trim($(this).text());
        }).get();

        // console.log("existing fields");
        // console.log(existing_fields);

        var new_fields = data.filter(f => !existing_fields.includes(f));
        var any_suggestions = new_fields.length > 0;
        if (any_suggestions) {
          result_container.html('');
          $.each(new_fields, function(i, value) {
            // console.log("New suggestion: ");
            // console.log(value);
            result_container.append(
              $('<a />')
                .attr('href', '#')
                .addClass('field-suggestion-link chip hoverable')
                .text(value)
                .on('click', function () {
                  $('.js-field-input').text($(this).text());
                  $('.js-field-input').siblings('label').addClass('active');
                  return false;
                })
            );
          });
        } else {
          result_container.text("It doesn't look like there are any suggestions right now. Since our suggestions are constantly growing, check back later and there might be more!");
        }
      }
    });

    $(this).hide();
    return false;
  });
});