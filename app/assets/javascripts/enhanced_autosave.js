$(document).ready(function() {
  var recent_autosave = false;
  var autosave_timers = {};
  var input_debounce_timers = {};

  function showToast(message, type = 'success') {
    // Remove any existing toasts
    $('.js-autosave-toast').remove();
    
    var bgClass = type === 'success' ? 'bg-green-500' : type === 'error' ? 'bg-red-500' : 'bg-yellow-500';
    var toast = $(`
      <div class="js-autosave-toast fixed top-4 right-4 z-50 px-4 py-2 text-white text-sm rounded-lg shadow-lg ${bgClass} transform transition-all duration-300 translate-x-full opacity-0">
        ${message}
      </div>
    `);
    
    $('body').append(toast);
    
    // Animate in
    setTimeout(() => {
      toast.removeClass('translate-x-full opacity-0');
    }, 100);
    
    // Animate out after delay
    setTimeout(() => {
      toast.addClass('translate-x-full opacity-0');
      setTimeout(() => toast.remove(), 300);
    }, type === 'error' ? 4000 : 2000);
  }

  function updateFieldVisualState(field, state) {
    // Remove all autosave-related classes
    field.removeClass('border-gray-300 border-yellow-400 border-green-400 border-red-400 border-2 border-4');
    
    // Find the status element in the same container
    var statusElement = field.closest('.mt-4').find('.js-autosave-status');
    var statusText = statusElement.find('.js-status-text');
    
    switch(state) {
      case 'saving':
        field.addClass('border-yellow-400 border-2');
        statusElement.removeClass('hidden text-gray-400 text-green-600 text-red-600').addClass('text-yellow-600');
        statusText.text('Saving...');
        break;
      case 'saved':
        field.addClass('border-green-400 border-2');
        statusElement.removeClass('hidden text-gray-400 text-yellow-600 text-red-600').addClass('text-green-600');
        statusText.text('✓ Saved');
        break;
      case 'error':
        field.addClass('border-red-400 border-2');
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
      
      // Update visual state to saving
      updateFieldVisualState(field, 'saving');
      saveIndicator.addClass('hidden');
      showToast('Saving...', 'saving');

      $.ajax({
        url:  content_form.attr('action') + '.json',
        type: content_form.attr('method').toUpperCase(),
        data: form_data,
        success: function(response) {
          console.log('Autosave successful');
          updateFieldVisualState(field, 'saved');
          
          // Show "Saved!" indicator
          saveIndicator.removeClass('hidden');
          showToast('✓ Saved!', 'success');

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
          showToast('✗ Error saving', 'error');
          
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
      showToast('✗ Error: No form found', 'error');
    }
  }

  function setupAutosaveTimer(field) {
    var fieldId = field.attr('id') || field.attr('name') || Math.random().toString(36);
    
    // Clear existing timer for this field
    if (autosave_timers[fieldId]) {
      clearTimeout(autosave_timers[fieldId]);
    }
    
    // Show that changes are pending
    updateFieldVisualState(field, 'saving');
    
    // Set new timer for 10 seconds
    autosave_timers[fieldId] = setTimeout(function() {
      if (field.is(':focus') && field.val().trim().length > 0) {
        performAutosave(field);
      } else {
        // Reset visual state if we're not going to save
        updateFieldVisualState(field, 'default');
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

  // Enhanced autosave for serendipitous questions
  $('.js-enhanced-autosave').on('input', function() {
    var field = $(this);
    
    // Debounce input to avoid setting up too many timers during rapid typing
    debounceInput(field, function() {
      setupAutosaveTimer(field);
    }, 300); // 300ms debounce
  });

  $('.js-enhanced-autosave').on('blur', function() {
    var field = $(this);
    var fieldId = field.attr('id') || field.attr('name') || Math.random().toString(36);
    
    // Clear any pending timers since we're saving on blur
    if (autosave_timers[fieldId]) {
      clearTimeout(autosave_timers[fieldId]);
      delete autosave_timers[fieldId];
    }
    if (input_debounce_timers[fieldId]) {
      clearTimeout(input_debounce_timers[fieldId]);
      delete input_debounce_timers[fieldId];
    }
    
    // Only autosave if there's content
    if (field.val().trim().length > 0) {
      performAutosave(field);
    } else {
      // Reset visual state if no content to save
      updateFieldVisualState(field, 'default');
    }
  });

  // Focus event to reset any error states
  $('.js-enhanced-autosave').on('focus', function() {
    var field = $(this);
    var saveIndicator = field.siblings('.js-save-indicator');
    
    // Hide any existing save indicators when user starts editing again
    if (!saveIndicator.hasClass('hidden')) {
      setTimeout(function() {
        saveIndicator.addClass('hidden');
      }, 500);
    }
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