/**
 * Unified Autosave System
 *
 * This is the single autosave system for all field types. It handles:
 * - Text inputs/textareas: 300ms input debouncing, save on blur
 * - Selects/checkboxes/radios/hidden fields: Immediate save on change
 *
 * How to use: Add the class 'js-autosave' to any input element.
 * Optionally add a status indicator element nearby:
 *   <div class="js-autosave-status hidden"><span class="js-status-text"></span></div>
 */
$(document).ready(function() {
  var recent_autosave = false;
  var autosave_timers = {};
  var input_debounce_timers = {};
  var fields_dirty = {}; // Track if field has changed since focus

  // Determine if an element should save immediately (no debounce)
  // Selects, checkboxes, radios, and hidden fields save on change
  function isImmediateSaveElement(element) {
    var tagName = element.tagName.toLowerCase();
    var inputType = element.type ? element.type.toLowerCase() : '';
    return tagName === 'select' ||
           inputType === 'checkbox' ||
           inputType === 'radio' ||
           inputType === 'hidden';
  }

  function updateFieldVisualState(field, state) {
    // Remove all autosave-related classes
    field.removeClass('border-gray-300 border-yellow-400 border-green-400 border-red-400');
    
    // Find the status element in the same container (works with both dashboard and content edit pages)
    var statusElement = field.closest('.relative').find('.js-autosave-status');
    var statusText = statusElement.find('.js-status-text');
    
    switch(state) {
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

  function performAutosave(field) {
    var content_form = field.closest('form');
    var fieldId = field.attr('id') || field.attr('name') || 'unknown';

    if (content_form.length) {
      recent_autosave = true;
      setTimeout(() => recent_autosave = false, 1000);

      var form_data = content_form.serialize();
      form_data += "&authenticity_token=" + encodeURIComponent($('meta[name="csrf-token"]').attr('content'));

      var saveIndicator = field.siblings('.js-save-indicator');

      console.log('Autosaving field...');

      // Update visual state to saving (textarea border turns yellow)
      updateFieldVisualState(field, 'saving');
      saveIndicator.addClass('hidden');

      $.ajax({
        url:  content_form.attr('action') + '.json',
        type: content_form.attr('method').toUpperCase(),
        data: form_data,
        success: function(response) {
          console.log('Autosave successful');
          updateFieldVisualState(field, 'saved');

          // Reset dirty flag so we don't re-save unchanged content
          fields_dirty[fieldId] = false;

          // Dispatch autosave:success event for other listeners (e.g., unsaved changes warning)
          var event = new CustomEvent('autosave:success', {
            detail: { field: field[0], response: response }
          });
          document.dispatchEvent(event);

          // Show "Saved!" indicator
          saveIndicator.removeClass('hidden');
          window.showToast('Saved!', 'success');

          // Reset back to default coloring and hide indicator after 3 seconds
          setTimeout(function () {
            updateFieldVisualState(field, 'default');
            saveIndicator.addClass('hidden');
          }, 3000);
        },
        error: function(xhr, status, error) {
          console.log('Autosave error:', error);
          updateFieldVisualState(field, 'error');
          
          // Show error indicator with different styling
          saveIndicator.find('span').removeClass('bg-green-100 text-green-800').addClass('bg-red-100 text-red-800');
          saveIndicator.find('span').text('✗ Error saving');
          saveIndicator.removeClass('hidden');
          window.showToast('Error saving', 'error');
          
          // Reset error state after 5 seconds
          setTimeout(function() {
            updateFieldVisualState(field, 'default');
            saveIndicator.addClass('hidden');
            // Reset indicator styling for next use
            saveIndicator.find('span').removeClass('bg-red-100 text-red-800').addClass('bg-green-100 text-green-800');
            saveIndicator.find('span').text('✓ Saved!');
          }, 5000);
        }
      });
    } else {
      console.log('Error: no form found for autosave');
      window.showToast('Error: No form found', 'error');
    }
  }

  function setupAutosaveTimer(field) {
    var fieldId = field.attr('id') || field.attr('name') || Math.random().toString(36);

    // Clear existing timer for this field
    if (autosave_timers[fieldId]) {
      clearTimeout(autosave_timers[fieldId]);
    }

    // Don't show "Saving..." yet - we're just queuing the save for later.
    // The visual feedback will be shown when performAutosave() actually starts.

    // Set new timer for 10 seconds
    autosave_timers[fieldId] = setTimeout(function() {
      if (field.is(':focus') && fields_dirty[fieldId]) {
        performAutosave(field);
      }
      delete autosave_timers[fieldId];
    }, 10000);
  }

  function debounceInput(field, callback, delay) {
    var fieldId = field.attr('id') || field.attr('name') || Math.random().toString(36);
    
    if (input_debounce_timers[fieldId]) {
      clearTimeout(input_debounce_timers[fieldId]);
    }
    
    input_debounce_timers[fieldId] = setTimeout(function() {
      callback();
      delete input_debounce_timers[fieldId];
    }, delay);
  }

  // Autosave for text fields (with debouncing)
  // Use delegated event binding to work with dynamically added elements and survive page refresh timing issues
  $(document).on('input', '.js-autosave', function() {
    var field = $(this);
    var fieldId = field.attr('id') || field.attr('name') || 'unknown';

    // Mark field as dirty (has changes)
    fields_dirty[fieldId] = true;

    // Debounce input to avoid setting up too many timers during rapid typing
    debounceInput(field, function() {
      setupAutosaveTimer(field);
    }, 300); // 300ms debounce
  });

  $(document).on('blur', '.js-autosave', function() {
    var field = $(this);
    var fieldId = field.attr('id') || field.attr('name') || 'unknown';

    // Clear any pending timers since we're handling blur
    if (autosave_timers[fieldId]) {
      clearTimeout(autosave_timers[fieldId]);
      delete autosave_timers[fieldId];
    }
    if (input_debounce_timers[fieldId]) {
      clearTimeout(input_debounce_timers[fieldId]);
      delete input_debounce_timers[fieldId];
    }

    // Only autosave if field is dirty (user made changes)
    if (fields_dirty[fieldId]) {
      performAutosave(field);
    } else {
      // Reset visual state if no changes to save
      updateFieldVisualState(field, 'default');
    }
  });

  // Focus event to reset dirty flag and any error states
  $(document).on('focus', '.js-autosave', function() {
    var field = $(this);
    var fieldId = field.attr('id') || field.attr('name') || 'unknown';
    var saveIndicator = field.siblings('.js-save-indicator');

    // Reset dirty flag on focus (will be set true by input event if user types)
    fields_dirty[fieldId] = false;

    // Hide any existing save indicators when user starts editing again
    if (!saveIndicator.hasClass('hidden')) {
      setTimeout(function() {
        saveIndicator.addClass('hidden');
      }, 500);
    }
  });

  // Immediate save on change for selects, checkboxes, radios, hidden fields
  $(document).on('change', '.js-autosave', function() {
    var field = $(this);
    if (isImmediateSaveElement(this)) {
      performAutosave(field);
    }
  });

  // Click-to-submit handler (migrated from autosave.js)
  $(document).on('click', '.submit-closest-form-on-click', function() {
    $(this).closest('form').submit();
  });

  // Clear timers on page unload to prevent memory leaks
  window.addEventListener('beforeunload', function() {
    Object.keys(autosave_timers).forEach(function(fieldId) {
      clearTimeout(autosave_timers[fieldId]);
    });
    Object.keys(input_debounce_timers).forEach(function(fieldId) {
      clearTimeout(input_debounce_timers[fieldId]);
    });
  });
}); 