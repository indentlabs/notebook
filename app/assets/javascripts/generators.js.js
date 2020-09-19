/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(document).ready(function() {

  // Character name generator
  $('.character_name_generator').click(function() {
    const target = $(this).closest('.row').find('input[type=text]');
    $.ajax({
      dataType: 'text',
      url:      '/generate/character/name',
      success(data) {
        return target.val(data);
      }
    });
    return 0;
  });

  // Character age generator
  $('.character_age_generator').click(function() {
    const target = $(this).closest('.row').find('input[type=text]');
    $.ajax({
      dataType: 'text',
      url:      '/generate/character/age',
      success(data) {
        return target.val(data);
      }
    });
    return 0;
  });

  // Location name generator
  return $('.location_name_generator').click(function() {
    const target = $(this).closest('.row').find('input[type=text]');
    $.ajax({
      dataType: 'text',
      url:      '/generate/location/name',
      success(data) {
        return target.val(data);
      }
    });
    return 0;
  });
});
