/**
 * Dice button for fields with a pool of suggested answers.
 *
 * Clicking a '.js-roll-field-dice' button fills its field with a random choice from the button's
 * data-choices JSON array. Each roll picks something different from what's already in the field
 * (when there's more than one choice), so users can keep clicking until they like the answer.
 */
$(document).ready(function() {
  function pickRandomChoice(choices, currentValue) {
    var candidates = choices.filter(function(choice) { return choice !== currentValue; });
    if (candidates.length === 0) {
      candidates = choices;
    }
    return candidates[Math.floor(Math.random() * candidates.length)];
  }

  $(document).on('click', '.js-roll-field-dice', function(event) {
    event.preventDefault();

    var button  = $(this);
    var choices = button.data('choices') || [];
    var field   = button.closest('.js-field-with-tools').find('textarea').first();
    if (!field.length || choices.length === 0) {
      return;
    }

    field.val(pickRandomChoice(choices, field.val()));

    // Let everything listening for typing (resizing, word counts, unsaved indicators) catch up
    field[0].dispatchEvent(new Event('input', { bubbles: true }));
    field.trigger('autosave:request');

    // The input event above queues a jQuery UI autocomplete search; cancel it so the suggestion
    // menu doesn't pop open for the answer we just rolled
    var autocomplete = field.data('ui-autocomplete');
    if (autocomplete) {
      clearTimeout(autocomplete.searching);
      autocomplete.close();
    }

    // A quick spin so repeated rolls feel like rolls
    var icon = button.find('.material-icons')[0];
    if (icon && icon.animate) {
      icon.animate(
        [{ transform: 'rotate(0deg)' }, { transform: 'rotate(360deg)' }],
        { duration: 300, easing: 'ease-out' }
      );
    }
  });
});
