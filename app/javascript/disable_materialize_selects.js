// Disable MaterializeCSS select initialization on Tailwind pages
document.addEventListener('DOMContentLoaded', function() {
  // Check if we're on a Tailwind page
  if (document.body.getAttribute('data-in-app') === 'true') {
    // If MaterializeCSS is loaded and has a FormSelect component
    if (window.M && window.M.FormSelect) {
      // Store the original FormSelect init function
      const originalFormSelect = window.M.FormSelect;
      
      // Override the FormSelect init function to do nothing for Tailwind-styled selects
      window.M.FormSelect = function(el, options) {
        // If the select has Tailwind classes, don't initialize MaterializeCSS on it
        if (el.classList.contains('form-select') || 
            el.closest('.tailwind-styled-form') !== null) {
          return;
        }
        
        // Otherwise, use the original initialization
        return new originalFormSelect(el, options);
      };
      
      // Also prevent auto-initialization
      document.querySelectorAll('select.form-select').forEach(function(select) {
        select.classList.add('no-autoinit');
      });
    }
  }
});