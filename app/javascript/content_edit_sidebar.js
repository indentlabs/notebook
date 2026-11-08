// Content edit page sidebar functionality
// Handles autosave status display, keyboard shortcuts, and word count

document.addEventListener('DOMContentLoaded', function() {
  // Only initialize if we're on a content edit page with the sidebar
  if (!document.getElementById('save-indicator')) return;

  initializeKeyboardShortcuts();
  initializeAutosaveListeners();
  initializeWordCount();
});

// Detect OS and update keyboard shortcut displays
function initializeKeyboardShortcuts() {
  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0 ||
                navigator.userAgent.toUpperCase().indexOf('MAC') >= 0;

  document.querySelectorAll('.keyboard-shortcut-save').forEach(function(element) {
    element.textContent = isMac ? '⌘S' : 'Ctrl+S';
  });
}

// Set up autosave status indicator listeners
function initializeAutosaveListeners() {
  // Update save status on success
  document.addEventListener('autosave:success', function() {
    const lastSavedEl = document.getElementById('last-saved');
    const saveIndicator = document.getElementById('save-indicator');
    const saveText = saveIndicator?.parentElement.querySelector('span');

    if (lastSavedEl) {
      lastSavedEl.textContent = new Date().toLocaleTimeString();
    }
    if (saveIndicator) {
      saveIndicator.className = 'w-2 h-2 bg-green-400 rounded-full mr-2';
    }
    if (saveText) {
      saveText.textContent = 'Saved';
      saveText.className = 'text-sm text-gray-700 dark:text-gray-300';
    }
  });

  // Show saving status when autosave starts
  document.addEventListener('autosave:start', function() {
    const saveIndicator = document.getElementById('save-indicator');
    const saveText = saveIndicator?.parentElement.querySelector('span');

    if (saveIndicator) {
      saveIndicator.className = 'w-2 h-2 bg-yellow-400 rounded-full mr-2';
    }
    if (saveText) {
      saveText.textContent = 'Saving...';
      saveText.className = 'text-sm text-yellow-700 dark:text-yellow-400';
    }
  });

  // Show unsaved changes when user starts typing
  document.addEventListener('input', function(e) {
    if (e.target.matches('.js-autosave')) {
      const saveIndicator = document.getElementById('save-indicator');
      const saveText = saveIndicator?.parentElement.querySelector('span');

      if (saveIndicator) {
        saveIndicator.className = 'w-2 h-2 bg-amber-400 rounded-full mr-2';
      }
      if (saveText) {
        saveText.textContent = 'Unsaved changes';
        saveText.className = 'text-sm text-amber-700 dark:text-amber-400';
      }

      // Update word count (debounced)
      debouncedWordCountUpdate();
    }
  });
}

// Word count functionality
let wordCountTimeout = null;

function initializeWordCount() {
  updatePageWordCount();
}

// Count words the same way the server does (window.NotebookWordCount, from
// app/assets/javascripts/word_count.js, mirrors WordCountService).
function countWordsInText(text) {
  return window.NotebookWordCount ? window.NotebookWordCount.count(text || '') : 0;
}

// Aggregate word count from the page's prose fields. Name and text fields are textareas; the
// universe, tags and link pickers are selects and hidden inputs whose values aren't prose, and the
// server doesn't count them either.
function calculatePageWordCount() {
  let totalWords = 0;
  document.querySelectorAll('textarea.js-autosave').forEach(function(field) {
    totalWords += countWordsInText(field.value);
  });
  return totalWords;
}

// Update display with number formatting. The sidebar is rendered twice (desktop and the mobile
// drawer), so update every copy rather than just the first element with this id.
function updatePageWordCount() {
  const wordCountEls = document.querySelectorAll('[id="page-word-count"]');
  if (wordCountEls.length === 0) return;

  const count = calculatePageWordCount().toLocaleString();
  wordCountEls.forEach(function(el) { el.textContent = count; });
}

// Debounced word count update (500ms, matches document editor)
function debouncedWordCountUpdate() {
  clearTimeout(wordCountTimeout);
  wordCountTimeout = setTimeout(updatePageWordCount, 500);
}

// Export for potential use elsewhere
window.updatePageWordCount = updatePageWordCount;
