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
  
  // Initialize tooltips
  document.querySelectorAll('[data-tooltip]').forEach(element => {
    const tooltipText = element.getAttribute('data-tooltip');
    
    element.addEventListener('mouseenter', function(e) {
      const tooltip = document.createElement('div');
      tooltip.className = 'absolute z-10 px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg shadow-sm tooltip';
      tooltip.textContent = tooltipText;
      tooltip.style.top = `${e.target.offsetTop - 40}px`;
      tooltip.style.left = `${e.target.offsetLeft + (e.target.offsetWidth / 2) - 80}px`;
      
      document.body.appendChild(tooltip);
      
      // Position tooltip
      const rect = tooltip.getBoundingClientRect();
      if (rect.left < 0) {
        tooltip.style.left = '0px';
      } else if (rect.right > window.innerWidth) {
        tooltip.style.left = `${window.innerWidth - rect.width - 10}px`;
      }
      
      // Add arrow
      const arrow = document.createElement('div');
      arrow.className = 'tooltip-arrow';
      arrow.style.position = 'absolute';
      arrow.style.width = '10px';
      arrow.style.height = '10px';
      arrow.style.background = '#1F2937';
      arrow.style.transform = 'rotate(45deg)';
      arrow.style.bottom = '-5px';
      arrow.style.left = 'calc(50% - 5px)';
      tooltip.appendChild(arrow);
    });
    
    element.addEventListener('mouseleave', function() {
      const tooltip = document.querySelector('.tooltip');
      if (tooltip) {
        document.body.removeChild(tooltip);
      }
    });
  });
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