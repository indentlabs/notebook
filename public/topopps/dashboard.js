$(document).ready(function () {
  $('.nav-sidebar .sidebar-dropdown-toggle').click(function(e) {
    var target = $(e.target).parent().find('.sidebar-dropdown-menu');
    
    target.toggle();
    if (target.is(':visible')) {
      target.parent().find('.caret').addClass('caret-reversed');
    } else {
      target.parent().find('.caret').removeClass('caret-reversed');
    }
  });

  $('.ttip-trigger').tooltip();
});
