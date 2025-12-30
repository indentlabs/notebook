// want to add new keyboard controls? Go to keyboardControllsMapping.js

function keyboardControlManager ( keyboardControls ) {
	/**
	 * Listens to the keyboard events and pushes items into the stack
	 *
	 * @param {KeyboardEvent} event
	 */
	function keyListener ( event ) {
		// must ignore modifier keys
		var ignored_keys = [
			16, // shift
			17, // osx control
			18, // osx alt/option
			91 // osx CMD / win CTRL
		];

		if( ignored_keys.indexOf(event.keyCode) !== -1 ){
			return;
		}

		// must ignore if currently focused into a text field
		if ( document.querySelector("input[type=\"text\"]:focus, textarea:focus") ){
			return;
		}

		// must ignore if currently focused in a contenteditable element (e.g. MediumEditor)
		var activeEl = document.activeElement;
		if (activeEl && (activeEl.isContentEditable || activeEl.closest('[contenteditable="true"]'))) {
			return;
		}

		// if not modifier, continue
		stackManager.add({
			"key" : event.keyCode,
			"shiftKey" : event.shiftKey,
			"ctrlKey" : event.ctrlKey
		});
	}

	/**
	 * on every stack update, we compare against our keyboardControls object
	 *
	 * @param {any} keyStackArray
	 *
	 * @returns boolean;
	 */
	function onStackUpdate ( keyStackArray ){
		for ( var i in keyboardControls ){
			var kc = keyboardControls[i];

			if(_.isEqual(kc.input, keyStackArray)){
				kc.result();
				return true;
			}
		};

		return false;
	}

	document.addEventListener("keyup", keyListener);
	var stackManager = KeyboardControlStackManager(1000, onStackUpdate);
}

/**
 *
 *
 * @param {number} entryTime The time required between keypresses
 * @param {function} stackEvaluationFunction the function to evaluate the stack once it's finalized. should return TRUE if a match is found
 *
 */
function KeyboardControlStackManager( entryTime, stackEvaluationFunction ) {
	var entryTime = entryTime;
	var timer = undefined;
	var currentStack = [];
	var stackEvaluationFunction = stackEvaluationFunction;

	/**
	 * Adds an element to the currentStack
	 *
	 * @param {{key : number, shiftKey : boolean, ctrlKey : boolean}} standardKeyStructure
	 *
	 */
	function add ( standardKeyStructure ) {
		currentStack.push( standardKeyStructure );
		if( timer ){
			clearTimeout(timer);
			timer = undefined;
		}
		timer = setTimeout(function () {
			timerComplete();
		},entryTime);

		// if it's found, clear the timer & stack
		if(stackEvaluationFunction(currentStack)){
			this.timerComplete();
		}
	}

	/**
	 * handles the completion of the timer and clears the stack
	 *
	 *
	 * @memberOf KeyboardControlStackManager
	 */
	function timerComplete () {
		currentStack = [];
		timer = undefined;
	}

	return {
		add : add,
		timerComplete : timerComplete
	}
}
$(document).ready( function () {
	if (document.querySelector("body[data-in-app]")) {
		if ((typeof DISABLE_KEYBOARD_SHORTCUTS === 'undefined' || !DISABLE_KEYBOARD_SHORTCUTS)) {
			keyboardControlManager(default_keyboard_controls);
			console.log('Keyboard shortcuts are enabled on this page');
		} else {
			console.log('Keyboard shortcuts are disabled on this page.');
		}
	}
});
