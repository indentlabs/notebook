// Document Editor JavaScript
// Medium Editor initialization, autosave, and metadata modal handling.
// For use with the Tailwind CSS-based document editor.

document.addEventListener('DOMContentLoaded', function() {
  // Only initialize if we're on the document edit page
  const editorElement = document.getElementById('editor');
  if (!editorElement) return;

  // Initialize Medium Editor
  window.editor = new MediumEditor('#editor', {
    targetBlank: true,
    autoLink: false,
    buttonLabels: 'fontawesome',
    placeholder: {
      text: 'Write as little or as much as you want!',
      hideOnClick: false
    },
    toolbar: {
      buttons: [
        'bold',
        'italic',
        'underline',
        'strikethrough',
        {
          name: 'h1',
          action: 'append-h2',
          aria: 'header type 1',
          tagNames: ['h2'],
          contentDefault: '<b>H1</b>',
          classList: ['custom-class-h1'],
          attrs: {'data-custom-attr': 'attr-value-h1'}
        },
        {
          name: 'h2',
          action: 'append-h3',
          aria: 'header type 2',
          tagNames: ['h3'],
          contentDefault: '<b>H2</b>',
          classList: ['custom-class-h2'],
          attrs: {'data-custom-attr': 'attr-value-h2'}
        },
        {
          name: 'h3',
          action: 'append-h4',
          aria: 'header type 3',
          tagNames: ['h4'],
          contentDefault: '<b>H3</b>',
          classList: ['custom-class-h3'],
          attrs: {'data-custom-attr': 'attr-value-h3'}
        },
        'justifyLeft',
        'justifyCenter',
        'justifyRight',
        'justifyFull',
        'orderedlist',
        'unorderedlist',
        'quote',
        'anchor',
        'removeFormat'
      ]
    },
    anchorPreview: {
      hideDelay: 0
    },
    paste: {
      forcePlainText: false
    }
  });

  // Strip background colors when copying to prevent dark mode backgrounds in clipboard
  editorElement.addEventListener('copy', function(e) {
    const selection = window.getSelection();
    if (!selection.rangeCount) return;

    // Get the selected HTML
    const range = selection.getRangeAt(0);
    const div = document.createElement('div');
    div.appendChild(range.cloneContents());

    // Remove background colors from all elements
    div.querySelectorAll('*').forEach(function(el) {
      el.style.removeProperty('background-color');
      el.style.removeProperty('background');
    });

    // Also clean inline style attributes that may contain background
    const html = div.innerHTML.replace(/background(-color)?:\s*[^;]+;?/gi, '');

    // Set the cleaned content on the clipboard
    e.clipboardData.setData('text/html', html);
    e.clipboardData.setData('text/plain', selection.toString());
    e.preventDefault();
  });

  // Add tooltips to toolbar buttons
  setTimeout(function() {
    const tooltips = {
      'bold': 'Bold (Ctrl+B)',
      'italic': 'Italic (Ctrl+I)',
      'underline': 'Underline (Ctrl+U)',
      'strikethrough': 'Strikethrough',
      'append-h2': 'Heading 1',
      'append-h3': 'Heading 2',
      'append-h4': 'Heading 3',
      'justifyLeft': 'Align Left',
      'justifyCenter': 'Align Center',
      'justifyRight': 'Align Right',
      'justifyFull': 'Justify',
      'insertorderedlist': 'Numbered List',
      'insertunorderedlist': 'Bullet List',
      'append-blockquote': 'Block Quote',
      'createLink': 'Insert Link (Ctrl+K)',
      'removeFormat': 'Clear Formatting'
    };

    document.querySelectorAll('.medium-editor-action').forEach(function(btn) {
      const action = btn.getAttribute('data-action');
      if (tooltips[action]) {
        btn.setAttribute('title', tooltips[action]);
      }
    });
  }, 100);

  // Set up CSRF token for AJAX requests
  $.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });

  // Autosave variables
  let short_timer = null;           // Timer that resets on each change (2 seconds)
  let long_timer = null;            // Timer that forces save after 30 seconds
  let last_autosave = null;         // Last AJAX request
  let first_change_time = null;     // When the first unsaved change was made
  let has_unsaved_changes = false;  // Whether we have unsaved changes
  let autosave_hide_timeout = null; // Timeout for hiding success indicator

  // Function to perform the actual save
  const performSave = function() {
    console.log('Performing save');

    // Update save indicator to saving state (subtle)
    $('.js-autosave-status').text('Saving...');
    $('.js-autosave-icon').text('cloud_upload').addClass('text-gray-400').removeClass('text-gray-500 text-red-400');
    $('#save-indicator').removeClass('bg-red-500/80').addClass('bg-gray-100/80 dark:bg-gray-800/80 pulse-animation');
    $('.js-autosave-status').removeClass('text-white').addClass('text-gray-500 dark:text-gray-400');

    // Update mini save indicator
    $('#mini-save-indicator i').addClass('pulse-animation');

    // Clear both timers
    clearTimeout(short_timer);
    clearTimeout(long_timer);
    short_timer = null;
    long_timer = null;

    // Reset change tracking
    first_change_time = null;
    has_unsaved_changes = false;

    // Do the autosave
    last_autosave = $.ajax({
      type: 'PATCH',
      url: $('#editor').data('save-url'),
      data: {
        document: {
          title: $('#document_title').val(),
          body: $('#editor').html()
        }
      }
    });

    last_autosave.fail(function(jqXHR, textStatus) {
      // Update indicator to error state (subtle red)
      $('.js-autosave-status').text('Error!');
      $('.js-autosave-icon').text('cloud_off').addClass('text-white').removeClass('text-gray-400 text-gray-500');
      $('#save-indicator').removeClass('bg-gray-100/80 dark:bg-gray-800/80 bg-green-100/80').addClass('bg-red-500/90');
      $('.js-autosave-status').removeClass('text-gray-500 dark:text-gray-400').addClass('text-white');

      // Mark that we still have unsaved changes
      has_unsaved_changes = true;
    });

    last_autosave.done(function() {
      // Update indicator to saved state (subtle)
      $('.js-autosave-status').text('Saved');
      $('.js-autosave-icon').text('cloud_done').addClass('text-gray-400 dark:text-gray-500').removeClass('text-white text-red-400');
      $('#save-indicator').removeClass('bg-red-500/90 pulse-animation').addClass('bg-gray-100/80 dark:bg-gray-800/80');
      $('.js-autosave-status').removeClass('text-white').addClass('text-gray-500 dark:text-gray-400');

      // Update mini save indicator
      $('#mini-save-indicator i').removeClass('pulse-animation');

      // Brief subtle green flash for success
      $('#save-indicator').addClass('bg-green-100/80 dark:bg-green-900/30');
      clearTimeout(autosave_hide_timeout);
      autosave_hide_timeout = setTimeout(function() {
        $('#save-indicator').removeClass('bg-green-100/80 dark:bg-green-900/30');
      }, 800);
    });
  };

  // Function to queue an autosave after a change
  const queueAutosave = function() {
    // If this is the first unsaved change, record the time
    if (!has_unsaved_changes) {
      first_change_time = new Date();
      has_unsaved_changes = true;

      // Set long timer for 30 seconds (won't be reset by further changes)
      if (!long_timer) {
        long_timer = setTimeout(function() {
          console.log('Long timer triggered - 30 seconds since first change');
          performSave();
        }, 30000); // 30 seconds
      }
    }

    // Update indicator to show pending changes (subtle)
    $('.js-autosave-status').text('Unsaved');
    $('.js-autosave-icon').text('edit');

    // Clear and reset the short timer (500ms)
    clearTimeout(short_timer);
    short_timer = setTimeout(function() {
      console.log('Short timer triggered - 500ms since last change');
      performSave();
    }, 500); // 500ms
  };

  // Function to count words - simple whitespace split
  // Note: Server-side WordCountService is authoritative; this is an approximation for real-time display
  const countWords = function() {
    const text = document.getElementById('editor').textContent || '';
    if (text.length === 0) return 0;
    return text.trim().split(/\s+/).filter(function(w) { return w.length > 0; }).length;
  };

  // Function to count characters (uses textContent for efficiency)
  const countCharacters = function() {
    const text = document.getElementById('editor').textContent || '';
    return text.length;
  };

  // Function to calculate reading time (avg 200 words per minute)
  const calculateReadingTime = function(wordCount) {
    const minutes = Math.ceil(wordCount / 200);
    return minutes < 1 ? '<1' : minutes.toString();
  };

  // Update word count display
  const updateWordCount = function() {
    // Use optimized functions that read textContent directly
    const wordCount = countWords();
    const charCount = countCharacters();
    const readingTime = calculateReadingTime(wordCount);

    // Update navbar word count
    $('#word-count').text(wordCount);
    $('#mini-word-count').text(wordCount);

    // Update sidebar stats
    $('#sidebar-word-count').text(wordCount);
    $('#sidebar-char-count').text(charCount.toLocaleString());
    $('#sidebar-reading-time').text(readingTime);

    // Restore "fresh" state on word count circle - change back to teal gradient
    $('#word-count-circle')
      .removeClass('from-gray-400 to-gray-500')
      .addClass('from-teal-400 to-teal-600');
  };

  // Initial word count
  updateWordCount();

  // Debounced word count to prevent performance issues on large documents
  let wordCountTimeout = null;
  const debouncedWordCount = function() {
    clearTimeout(wordCountTimeout);
    wordCountTimeout = setTimeout(updateWordCount, 500); // Max 2x/sec instead of 60x/sec
  };

  // Trigger autosave and update word count on content changes
  window.editor.subscribe('editableInput', function() {
    // Queue an autosave
    queueAutosave();
    // Show "stale" state on word count circle - change to gray gradient
    $('#word-count-circle')
      .removeClass('from-teal-400 to-teal-600')
      .addClass('from-gray-400 to-gray-500');
    // Update word count (debounced for performance on large docs)
    debouncedWordCount();
  });

  // Trigger autosave on title changes
  $('#document_title').on('change', function() {
    queueAutosave();
  });

  $('#document_title').on('keyup', function() {
    if ($(this).val().length > 0) {
      queueAutosave();
    }
  });

  // Manual save on click - immediate save, not queued
  $('.js-autosave-status').on('click', performSave);

  // Set up beforeunload handler to warn about unsaved changes
  window.addEventListener('beforeunload', function(e) {
    // Only show warning if we have unsaved changes
    if (has_unsaved_changes) {
      // Modern browsers
      e.preventDefault();
      e.returnValue = ''; // Chrome requires this

      // Legacy browsers (return value is ignored in modern browsers)
      return 'You have unsaved changes. Are you sure you want to leave?';
    }
  });

  // Alternative legacy approach for older browsers
  window.onbeforeunload = function() {
    if (has_unsaved_changes) {
      return 'You have unsaved changes. Are you sure you want to leave?';
    }
  };

  // Allow entering `tab` into the editor
  $(document).delegate('#editor', 'keydown', function(e) {
    const keyCode = e.keyCode || e.which;
    if (keyCode === 9) {
      e.preventDefault();
    }
  });

  // Keyboard shortcuts
  $(document).on('keydown', function(e) {
    // Save (Ctrl+S)
    if (e.ctrlKey && e.key === 's') {
      e.preventDefault();
      performSave();
    }
  });

  // Handle Save & Close button click for all metadata modals
  $('.save-metadata-button').on('click', function() {
    // Get the form closest to this button
    const form = $(this).closest('form.metadata-form');

    // Show saving state
    const button = $(this);
    const originalText = button.text();
    button.html('<i class="material-icons text-sm align-middle mr-1">hourglass_top</i> Saving...');
    button.prop('disabled', true);

    // Submit the form via AJAX
    $.ajax({
      type: 'PATCH',
      url: form.attr('action'),
      data: form.serialize(),
      success: function() {
        // Show success state
        button.html('<i class="material-icons text-sm align-middle mr-1">check</i> Saved!');

        // Close the modal after a short delay
        setTimeout(function() {
          // Reset button
          button.html(originalText);
          button.prop('disabled', false);

          // The modal should already be closed by the @click="open = false" on the button
        }, 1000);
      },
      error: function() {
        // Show error state
        button.html('<i class="material-icons text-sm align-middle mr-1">error</i> Error!');

        // Reset button after delay
        setTimeout(function() {
          button.html(originalText);
          button.prop('disabled', false);
        }, 2000);
      }
    });
  });
});
