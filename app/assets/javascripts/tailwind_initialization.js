//# Initialization for Tailwind pages
//# This file contains initialization code for Tailwind pages without MaterializeCSS

if (!window.Notebook) { window.Notebook = {}; }
Notebook.tailwindInit = function() {
  // Initialize non-MaterializeCSS components here

  // Character counters for textareas and inputs with maxlength
  document.querySelectorAll('[maxlength]').forEach(function(element) {
    const maxLength = element.getAttribute('maxlength');
    const counter = document.createElement('div');
    counter.className = 'text-xs text-right text-gray-500 mt-1';
    counter.innerHTML = `<span class="current-length">${element.value.length}</span>/${maxLength}`;
    element.parentNode.appendChild(counter);
    
    element.addEventListener('input', function() {
      const currentLength = this.value.length;
      const counterElement = this.parentNode.querySelector('.current-length');
      counterElement.textContent = currentLength;
      
      if (currentLength > maxLength) {
        counterElement.classList.add('text-red-500');
      } else {
        counterElement.classList.remove('text-red-500');
      }
    });
  });

  // Tooltips are handled via CSS-only (see application.css)
  // Use classes: tooltip-left, tooltip-right, tooltip-top, tooltip-bottom
  // With attribute: data-tooltip="Your tooltip text"
};

// Initialize on DOM ready for Tailwind pages
document.addEventListener('DOMContentLoaded', function() {
  // Only run on Tailwind pages
  if (document.body && document.body.getAttribute('data-in-app') === 'true') {
    if (window.Notebook && window.Notebook.tailwindInit) {
      Notebook.tailwindInit();
    }
  }
});