$(document).ready(function () {
  $('.js-show-answer-suggestions').click(function () {
    var content_type = $(this).data('content-type');
    var category_id  = $(this).data('category-id');
    var field_label  = $(this).data('field-label');

    $.ajax({
      dataType: "json",
      url: "/api/v1/answers/suggest/" + content_type + "/" + field_label,
      success: function (data) {
        console.log(data);
        // var existing_fields = result_container.closest('.js-category-container').find('.js-field-label').map(function(){
        //   return $.trim($(this).text());
        // }).get();

        // console.log("existing fields");
        // console.log(existing_fields);

        // var new_fields = data.filter(f => !existing_fields.includes(f));
        // var any_suggestions = new_fields.length > 0;
        // if (any_suggestions) {
        //   result_container.html('');
        //   $.each(new_fields, function(i, value) {
        //     console.log("New suggestion: ");
        //     console.log(value);
        //     result_container.append(
        //       $('<a />')
        //         .attr('href', '#')
        //         .addClass('field-suggestion-link chip hoverable')
        //         .text(value)
        //         .on('click', function () {
        //           $('.js-field-input').text($(this).text());
        //           $('.js-field-input').siblings('label').addClass('active');
        //           return false;
        //         })
        //     );
        //   });
        // } else {
        //   result_container.text("It doesn't look like there are any suggestions right now. Since our suggestions are constantly growing, check back later and there might be more!");
        // }
        
        $(this).fadeOut();
      }
    });

    return false;
  });
});