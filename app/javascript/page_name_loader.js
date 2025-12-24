/**
 * Page Name Loader
 * 
 * This script handles loading page names for elements with the js-load-page-name class.
 * It fetches page names from the API and updates the corresponding elements.
 */

document.addEventListener('DOMContentLoaded', function() {
  // Load page names for elements with the js-load-page-name class
  function loadPageNames() {
    document.querySelectorAll('.js-load-page-name').forEach(function(element) {
      const pageType = element.getAttribute('data-klass');
      const pageId = element.getAttribute('data-id');
      const nameContainer = element.querySelector('.name-container');
      
      if (!pageType || !pageId || !nameContainer) return;
      
      // Check if we've already loaded this name
      if (nameContainer.getAttribute('data-loaded') === 'true') return;
      
      // Mark as loading
      nameContainer.setAttribute('data-loading', 'true');
      
      // Fetch the page name from the API
      fetch(`/api/v1/page_name?type=${encodeURIComponent(pageType)}&id=${encodeURIComponent(pageId)}`)
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(data => {
          if (data && data.name) {
            nameContainer.textContent = data.name;
          } else {
            nameContainer.textContent = `Unnamed ${pageType}`;
          }
          nameContainer.setAttribute('data-loaded', 'true');
          nameContainer.removeAttribute('data-loading');
        })
        .catch(error => {
          console.error('Error loading page name:', error);
          nameContainer.textContent = `${pageType} #${pageId}`;
          nameContainer.setAttribute('data-loaded', 'true');
          nameContainer.removeAttribute('data-loading');
        });
    });
  }
  
  // Load page names on page load
  loadPageNames();
  
  // Also load page names when new content is added to the DOM
  // This is useful for dynamically loaded content
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.addedNodes && mutation.addedNodes.length > 0) {
        // Check if any of the added nodes have the js-load-page-name class
        // or contain elements with that class
        for (let i = 0; i < mutation.addedNodes.length; i++) {
          const node = mutation.addedNodes[i];
          if (node.nodeType === Node.ELEMENT_NODE) {
            if (node.classList && node.classList.contains('js-load-page-name')) {
              loadPageNames();
              break;
            } else if (node.querySelectorAll) {
              const hasLoadableElements = node.querySelectorAll('.js-load-page-name').length > 0;
              if (hasLoadableElements) {
                loadPageNames();
                break;
              }
            }
          }
        }
      }
    });
  });
  
  // Observe the entire document for changes
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
});