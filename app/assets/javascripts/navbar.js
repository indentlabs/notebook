$(document).ready(function () {
  $('.tab-link').click(function() {
    document.location = $(this).attr('href');
  });
});
