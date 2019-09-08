/**
 * Mapping of the keyboard controls to functions.
 *
 * If you'd like to add any new keyboard controls, this is the place to do it.'
 */

function keycode_for(letter) {
	// Pretty sure this only works for alphanumeric (e.g. ? is incorrect)
	// Since ? is the only symbol we're using now lets uh not talk about this
	if (letter == '?') {
		return 191;
	}

	return letter.toUpperCase().charCodeAt(0);
}

function add_redirect_shortcut(key_after_N, page_type) {
	active_redirect_shortcuts.push({
		page: page_type,
		key:  key_after_N
	});

	default_keyboard_controls.push(
		{
			"input" : [
				{ key : keycode_for("n"),         shiftKey : true, ctrlKey : false },
				{ key : keycode_for(key_after_N), shiftKey : false, ctrlKey : false }
			],
			"result" : function () {
				document.location.pathname = '/plan/' + page_type + '/new';
			}
		}
	);
}

var default_keyboard_controls = [
	// ? => keyboard control
	{
		"input" : [
			{ key : keycode_for('?'), shiftKey : true, ctrlKey : false }
		],
		"result" : function () {
			$("#keyboard-controls-help-modal").modal('open');
		}
	}
];

var active_redirect_shortcuts = [];
add_redirect_shortcut("b", "buildings");
add_redirect_shortcut("c", "characters");
add_redirect_shortcut("n", "conditions");
add_redirect_shortcut("u", "countries");
add_redirect_shortcut("r", "creatures");
add_redirect_shortcut("d", "deities");
add_redirect_shortcut("y", "floras");
add_redirect_shortcut("f", "foods");
add_redirect_shortcut("g", "governments");
add_redirect_shortcut("o", "groups");
add_redirect_shortcut("i", "items");
add_redirect_shortcut("j", "jobs");
add_redirect_shortcut("l", "landmarks");
add_redirect_shortcut("a", "languages");
add_redirect_shortcut("t", "locations");
add_redirect_shortcut("m", "magics");
add_redirect_shortcut("p", "planets");
add_redirect_shortcut("r", "races");
add_redirect_shortcut("x", "religions");
add_redirect_shortcut("s", "scenes");
add_redirect_shortcut("h", "schools");
add_redirect_shortcut("z", "sports");
add_redirect_shortcut("h", "technologies");
add_redirect_shortcut("w", "towns");
add_redirect_shortcut("m", "traditions");
add_redirect_shortcut("u", "universes");
add_redirect_shortcut("v", "vehicles");

