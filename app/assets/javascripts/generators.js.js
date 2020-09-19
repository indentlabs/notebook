$(document).ready(function() {

  // Character name generator
  $('.character_name_generator').click(function() {
    const target = $(this).closest('.row').find('input[type=text]');
    $.ajax({
      dataType: 'text',
      url:      '/generate/character/name',
      success(data) {
        target.val(data);
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
        target.val(data);
      }
    });
    return 0;
  });

  // Location name generator
  $('.location_name_generator').click(function() {
    const target = $(this).closest('.row').find('input[type=text]');
    $.ajax({
      dataType: 'text',
      url:      '/generate/location/name',
      success(data) {
        target.val(data);
      }
    });
    return 0;
  });
});
