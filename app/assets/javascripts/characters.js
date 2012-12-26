$(document).ready(function () {

	function show_tab(tab_name) {
		$('.tab').removeClass('active');
		$('#show_' + tab_name).parent().addClass('active');

		$('.section').hide();
		$('#' + tab_name + '_section').css('visibility','visible').hide().fadeIn('fast');
	};

	$('#show_appearance').click(function() { show_tab('appearance') });
	$('#show_social').click(function() { show_tab('social') });
	$('#show_behavior').click(function() { show_tab('behavior') });
	$('#show_history').click(function() { show_tab('history') });
	$('#show_favorites').click(function() { show_tab('favorites') });
	$('#show_relationships').click(function() { show_tab('relationships') });
	$('#show_more').click(function() { show_tab('more') });

	show_tab('appearance');

});
