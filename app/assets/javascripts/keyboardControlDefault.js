/**
 * Mapping of the keyboard controls to functions.
 * 
 * If you'd like to add any new keyboard controls, this is the place to do it.'
 */

var KEYCODES = {
	"?" : 191,
	"n" : 78, 
	"c" : 67, 
	"u" : 85, 
	"i" : 73, 
	"l" : 76 
};

var default_keyboard_controls = [
	// ? => keyboard control
	{
		"input" : [
			{ key : KEYCODES["?"], shiftKey : true, ctrlKey : false }
		],
		"result" : function () {
			$("#keyboard-controls-help-modal").openModal()
		}
	},

	// N+c => new character form
	{
		"input" : [
			{ key : KEYCODES["n"], shiftKey : true, ctrlKey : false },
			{ key : KEYCODES["c"], shiftKey : false, ctrlKey : false }
		],
		"result" : function () {
			document.location.pathname = "/plan/characters/new";
		}
	},

	// N+u => new universe form
	{
		"input" : [
			{ key : KEYCODES["n"], shiftKey : true, ctrlKey : false },
			{ key : KEYCODES["u"], shiftKey : false, ctrlKey : false }
		],
		"result" : function () {
			document.location.pathname = "/plan/universes/new";
		}
	},

	// N+l => new location form
	{
		"input" : [
			{ key : KEYCODES["n"], shiftKey : true, ctrlKey : false },
			{ key : KEYCODES["l"], shiftKey : false, ctrlKey : false }
		],
		"result" : function () {
			document.location.pathname = "/plan/locations/new";
		}
	},

	// N+i => new item form
	{
		"input" : [
			{ key : KEYCODES["n"], shiftKey : true, ctrlKey : false },
			{ key : KEYCODES["i"], shiftKey : false, ctrlKey : false }
		],
		"result" : function () {
			document.location.pathname = "/plan/items/new";
		}
	}
];