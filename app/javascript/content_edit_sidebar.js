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
    if (e.target.matches('.autosave-closest-form-on-change, .js-enhanced-autosave')) {
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

// Word count calculation - matches server-side WordCountAnalyzer behavior
function countWordsInText(text) {
  if (!text || text.length === 0) return 0;

  // Strip HTML tags (matches server's xhtml: 'remove' option)
  text = text.replace(/<[^>]*>/g, ' ');

  let count = 0;
  let inWord = false;
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    const isSpace = char === ' ' || char === '\n' || char === '\t' || char === '\r';
    if (!isSpace && !inWord) {
      count++;
      inWord = true;
    } else if (isSpace) {
      inWord = false;
    }
  }
  return count;
}

// Aggregate word count from all text fields on the page
function calculatePageWordCount() {
  let totalWords = 0;
  document.querySelectorAll('.autosave-closest-form-on-change, .js-enhanced-autosave').forEach(function(field) {
    totalWords += countWordsInText(field.value || '');
  });
  return totalWords;
}

// Update display with number formatting
function updatePageWordCount() {
  const wordCountEl = document.getElementById('page-word-count');
  if (wordCountEl) {
    const count = calculatePageWordCount();
    wordCountEl.textContent = count.toLocaleString();
  }
}

// Debounced word count update (500ms, matches document editor)
function debouncedWordCountUpdate() {
  clearTimeout(wordCountTimeout);
  wordCountTimeout = setTimeout(updatePageWordCount, 500);
}

// Export for potential use elsewhere
window.updatePageWordCount = updatePageWordCount;
