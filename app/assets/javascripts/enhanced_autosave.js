/**
 * Unified Autosave System
 *
 * Add the class 'js-autosave' to any input inside a form, and that form is saved over AJAX:
 * - Text inputs/textareas: saved 10 seconds after the last keystroke, and whenever they lose focus
 * - Selects/checkboxes/radios/hidden fields: saved as soon as they change
 * - Anything still unsaved when the page is closed or navigated away from is sent with a beacon
 *
 * Each form is saved independently, with at most one request in flight per form. Edits made while a
 * request is in flight are sent in a single follow-up request once it finishes, so saves reach the
 * server in order and nothing typed during a save is lost.
 *
 * A form only needs saving when its data differs from what was last sent, so repeated triggers
 * (blur, the idle timer, change events) never send the same data twice.
 *
 * Events: 'autosave:start', 'autosave:success' and 'autosave:error' are dispatched on the field and
 * bubble up to document. event.detail.field is the field, and event.detail.response is the server's
 * response on success.
 *
 * Optionally add a status indicator nearby:
 *   <div class="js-autosave-status hidden"><span class="js-status-text"></span></div>
 */
$(document).ready(function() {
  var IDLE_SAVE_DELAY_MS      = 10000;
  var SAVED_STATE_DURATION_MS = 3000;
  var ERROR_STATE_DURATION_MS = 5000;

  // Save state for each form element we've seen:
  //   saved:        the serialized form data the server last confirmed (undefined if unknown)
  //   inFlight:     the serialized form data currently being sent, or null
  //   pendingField: the field that asked to save while a request was in flight, saved once it finishes
  var formStates = new Map();

  function stateFor(form, savedData) {
    if (!formStates.has(form)) {
      formStates.set(form, { saved: savedData, inFlight: null, pendingField: null });
    }
    return formStates.get(form);
  }

  // Whether the form holds data the server doesn't have and isn't already being sent
  function hasUnsentChanges(form, state) {
    var latestSent = state.inFlight !== null ? state.inFlight : state.saved;
    return form.serialize() !== latestSent;
  }

  function withCsrfToken(formData) {
    return formData + '&authenticity_token=' + encodeURIComponent($('meta[name="csrf-token"]').attr('content'));
  }

  // Selects, checkboxes, radios, and hidden fields save on change instead of on typing/blur
  function isImmediateSaveElement(element) {
    var tagName = element.tagName.toLowerCase();
    var inputType = element.type ? element.type.toLowerCase() : '';
    return tagName === 'select' ||
           inputType === 'checkbox' ||
           inputType === 'radio' ||
           inputType === 'hidden';
  }

  function dispatchAutosaveEvent(field, name, detail) {
    field[0].dispatchEvent(new CustomEvent(name, {
      bubbles: true,
      detail: $.extend({ field: field[0] }, detail)
    }));
  }

  function updateFieldVisualState(field, state) {
    field.removeClass('border-gray-300 border-yellow-400 border-green-400 border-red-400');

    // Find the status element in the same container (works with both dashboard and content edit pages)
    var statusElement = field.closest('.relative').find('.js-autosave-status');
    var statusText = statusElement.find('.js-status-text');

    switch (state) {
      case 'saving':
        field.addClass('border-yellow-400');
        statusElement.removeClass('hidden text-gray-400 text-green-600 text-red-600').addClass('text-yellow-600');
        statusText.text('Saving...');
        break;
      case 'saved':
        field.addClass('border-green-400');
        statusElement.removeClass('hidden text-gray-400 text-yellow-600 text-red-600').addClass('text-green-600');
        statusText.text('✓ Saved');
        break;
      case 'error':
        field.addClass('border-red-400');
        statusElement.removeClass('hidden text-gray-400 text-yellow-600 text-green-600').addClass('text-red-600');
        statusText.text('✗ Error');
        break;
      default:
        field.addClass('border-gray-300');
        statusElement.addClass('hidden').removeClass('text-yellow-600 text-green-600 text-red-600').addClass('text-gray-400');
        statusText.text('');
        break;
    }
  }

  // Show a save state on the field; 'saved' and 'error' fade back to the default look after a while
  function setFieldState(field, state) {
    clearTimeout(field.data('autosaveResetTimer'));
    updateFieldVisualState(field, state);

    var duration = { saved: SAVED_STATE_DURATION_MS, error: ERROR_STATE_DURATION_MS }[state];
    if (duration) {
      field.data('autosaveResetTimer', setTimeout(function() {
        updateFieldVisualState(field, 'default');
      }, duration));
    }
  }

  function save(field) {
    var form = field.closest('form');
    if (!form.length) {
      console.log('Error: no form found for autosave');
      window.showToast('Error: No form found', 'error');
      return;
    }

    var state = stateFor(form[0]);
    if (!hasUnsentChanges(form, state)) {
      return;
    }

    if (state.inFlight !== null) {
      // Sent once the current request finishes, with whatever the form holds by then
      state.pendingField = field;
      return;
    }

    send(form, field, state);
  }

  function send(form, field, state) {
    var formData = form.serialize();
    state.inFlight = formData;

    setFieldState(field, 'saving');
    dispatchAutosaveEvent(field, 'autosave:start');

    $.ajax({
      url:  form.attr('action') + '.json',
      type: (form.attr('method') || 'post').toUpperCase(),
      data: withCsrfToken(formData)
    }).done(function(response) {
      state.saved = formData;
      setFieldState(field, 'saved');
      window.showToast('Saved!', 'success');
      dispatchAutosaveEvent(field, 'autosave:success', { response: response });
    }).fail(function(xhr, status, error) {
      // state.saved is left alone, so the form still counts as unsaved and the next trigger retries
      console.log('Autosave error:', error);
      setFieldState(field, 'error');
      window.showToast('Error saving', 'error');
      dispatchAutosaveEvent(field, 'autosave:error');
    }).always(function() {
      state.inFlight = null;

      var pendingField = state.pendingField;
      state.pendingField = null;
      if (pendingField) {
        save(pendingField);
      }
    });
  }

  // Record what the form holds before the user edits it, so leaving it unchanged doesn't save.
  // Only done the first time; after that, state.saved tracks what the server confirmed.
  $(document).on('focus', '.js-autosave', function() {
    var form = $(this).closest('form');
    if (form.length) {
      stateFor(form[0], form.serialize());
    }
  });

  // Text fields save once typing has paused for a while, even if the field keeps focus
  $(document).on('input', '.js-autosave', function() {
    if (isImmediateSaveElement(this)) {
      return;
    }

    var field = $(this);
    clearTimeout(field.data('autosaveIdleTimer'));
    field.data('autosaveIdleTimer', setTimeout(function() {
      save(field);
    }, IDLE_SAVE_DELAY_MS));
  });

  $(document).on('blur', '.js-autosave', function() {
    var field = $(this);
    clearTimeout(field.data('autosaveIdleTimer'));
    save(field);
  });

  $(document).on('change', '.js-autosave', function() {
    if (isImmediateSaveElement(this)) {
      save($(this));
    }
  });

  // An AJAX request can be cancelled when the page goes away, but a beacon is delivered after the page
  // is gone. Beacons are always POSTs, which Rails routes like the form's own request because the form
  // data carries its _method override.
  window.addEventListener('pagehide', function() {
    formStates.forEach(function(state, formElement) {
      var form = $(formElement);
      var isPostForm = (form.attr('method') || 'post').toLowerCase() === 'post';

      // Compared against confirmed data rather than in-flight data, since an in-flight request may be cancelled
      if (formElement.isConnected && isPostForm && form.serialize() !== state.saved) {
        navigator.sendBeacon(form.attr('action') + '.json', new URLSearchParams(withCsrfToken(form.serialize())));
      }
    });
  });

  // Click-to-submit handler (migrated from autosave.js)
  $(document).on('click', '.submit-closest-form-on-click', function() {
    $(this).closest('form').submit();
  });
});
