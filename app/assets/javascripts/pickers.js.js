$(document).ready(() => $('.dropdown-picker li a').click(function() {
  const val = $(this).text();
  $(this).closest('.row').find('input[type=text]').val(val);
}));
