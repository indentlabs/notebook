// Template Editor JavaScript

// Template Reset Component function for Alpine.js (define before DOM ready)
window.templateResetComponent = function() {
  return {
    resetOpen: false,
    resetConfirm: false,
    resetAnalysis: null,
    loading: false,
    confirmText: '',
    
    toggleReset() {
      this.resetOpen = !this.resetOpen;
      if (this.resetOpen && !this.resetAnalysis) {
        this.fetchAnalysis();
      }
    },
    
    fetchAnalysis() {
      console.log('Fetching reset analysis...');
      this.loading = true;
      const contentType = document.querySelector('.attributes-editor').dataset.contentType;
      
      fetch(`/plan/${contentType}/template/reset`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        console.log('Analysis data:', data);
        this.resetAnalysis = data;
        this.loading = false;
      })
      .catch(error => {
        console.error('Error:', error);
        this.loading = false;
        if (typeof showNotification === 'function') {
          showNotification('Failed to analyze template reset impact', 'error');
        } else {
          alert('Failed to analyze template reset impact');
        }
      });
    },
    
    performReset() {
      console.log('Performing reset...');
      this.loading = true;
      const contentType = document.querySelector('.attributes-editor').dataset.contentType;
      
      fetch(`/plan/${contentType}/template/reset?confirm=true`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          if (typeof showNotification === 'function') {
            showNotification(data.message, 'success');
          } else {
            alert(data.message);
          }
          setTimeout(() => window.location.reload(), 2000);
        } else {
          if (typeof showNotification === 'function') {
            showNotification(data.error || 'Failed to reset template', 'error');
          } else {
            alert(data.error || 'Failed to reset template');
          }
          this.loading = false;
        }
      })
      .catch(error => {
        console.error('Error:', error);
        if (typeof showNotification === 'function') {
          showNotification('Failed to reset template', 'error');
        } else {
          alert('Failed to reset template');
        }
        this.loading = false;
      });
    }
  };
};

// Initialize Alpine component data (global function)
window.initTemplateEditor = function() {
  return {
    selectedCategory: null,
    selectedField: null,
    configuring: false,
    activePanel: window.innerWidth >= 768 ? 'both' : 'template',
    
    // Initialize reset analysis as empty object to prevent Alpine errors
    resetAnalysis: null,
    
    // Category selection
    selectCategory(categoryId) {
      this.selectedCategory = categoryId;
      this.selectedField = null;
      this.configuring = true;
      
      if (window.innerWidth < 768) {
        this.activePanel = 'config';
      }
      
      // Show loading animation
      showConfigLoadingAnimation('category-config-container');
      
      // Load category configuration via AJAX
      fetch(`/plan/attribute_categories/${categoryId}/edit`)
        .then(response => response.text())
        .then(html => {
          document.getElementById('category-config-container').innerHTML = html;
          // Bind remote form handlers to newly loaded forms
          bindRemoteFormsInContainer('category-config-container');
          // Hide loading animation
          hideConfigLoadingAnimation('category-config-container');
        })
        .catch(error => {
          console.error('Error loading category config:', error);
          hideConfigLoadingAnimation('category-config-container');
          showNotification('Failed to load category configuration', 'error');
        });
    },
    
    // Field selection
    selectField(fieldId) {
      this.selectedField = fieldId;
      this.selectedCategory = null;
      this.configuring = true;
      
      if (window.innerWidth < 768) {
        this.activePanel = 'config';
      }
      
      // Show loading animation
      showConfigLoadingAnimation('field-config-container');
      
      // Load field configuration via AJAX
      fetch(`/plan/attribute_fields/${fieldId}/edit`)
        .then(response => response.text())
        .then(html => {
          document.getElementById('field-config-container').innerHTML = html;
          // Bind remote form handlers to newly loaded forms
          bindRemoteFormsInContainer('field-config-container');
          // Hide loading animation
          hideConfigLoadingAnimation('field-config-container');
        })
        .catch(error => {
          console.error('Error loading field config:', error);
          hideConfigLoadingAnimation('field-config-container');
          showNotification('Failed to load field configuration', 'error');
        });
    }
  };
};

document.addEventListener('DOMContentLoaded', function() {
  
  // Initialize sortable for categories
  initSortables();
  
  // Handle remote form submissions for dynamically loaded forms
  setupRemoteFormHandlers();
  
  // Show category form
  document.addEventListener('click', function(event) {
    if (event.target.closest('[data-action="click->attributes-editor#showAddCategoryForm"]')) {
      const form = document.getElementById('add-category-form');
      form.classList.toggle('hidden');
    }
  });
  
  // Handle select-category event dispatched from category cards
  document.addEventListener('select-category', function(event) {
    const alpineElement = document.querySelector('.attributes-editor');
    if (alpineElement && alpineElement._x_dataStack) {
      const alpine = alpineElement._x_dataStack[0];
      if (alpine.selectCategory) {
        alpine.selectCategory(event.detail.id);
      }
    }
  });
  
  // Handle select-field event dispatched from field items
  document.addEventListener('select-field', function(event) {
    const alpineElement = document.querySelector('.attributes-editor');
    if (alpineElement && alpineElement._x_dataStack) {
      const alpine = alpineElement._x_dataStack[0];
      if (alpine.selectField) {
        alpine.selectField(event.detail.id);
      }
    }
  });
  
  // Category suggestions
  document.querySelectorAll('.js-show-category-suggestions').forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const contentType = document.querySelector('.attributes-editor').dataset.contentType;
      const resultContainer = this.closest('div').querySelector('.suggest-categories-container');
      
      // Show loading animation in the suggestions container
      showSuggestionsLoadingAnimation(resultContainer);
      
      fetch(`/plan/attribute_categories/suggest?content_type=${contentType}`)
        .then(response => response.json())
        .then(data => {
          const existingCategories = Array.from(document.querySelectorAll('.category-label')).map(el => el.textContent.trim());
          const newCategories = data.filter(c => !existingCategories.includes(c));
          
          if (newCategories.length > 0) {
            resultContainer.innerHTML = '';
            newCategories.forEach(category => {
              const chip = document.createElement('span');
              chip.className = 'category-suggestion-link px-3 py-1 bg-gray-100 text-sm text-gray-800 rounded-full hover:bg-gray-200 cursor-pointer';
              chip.textContent = category;
              chip.addEventListener('click', function() {
                document.querySelector('.js-category-input').value = category;
              });
              resultContainer.appendChild(chip);
            });
          } else {
            resultContainer.innerHTML = '<p class="text-sm text-gray-500">No suggestions available at the moment.</p>';
          }
        })
        .catch(error => {
          console.error('Error loading category suggestions:', error);
          resultContainer.innerHTML = '<p class="text-sm text-red-500">Failed to load suggestions. Please try again.</p>';
        });
      
      this.style.display = 'none';
    });
  });
  
  // Field suggestions
  document.querySelectorAll('.js-show-field-suggestions').forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const contentType = document.querySelector('.attributes-editor').dataset.contentType;
      const categoryContainer = this.closest('li') || this.closest('.category-card');
      const categoryLabel = categoryContainer.querySelector('.category-label').textContent.trim();
      const resultContainer = this.closest('div').querySelector('.suggest-fields-container');
      
      // Show loading animation in the suggestions container
      showSuggestionsLoadingAnimation(resultContainer);
      
      fetch(`/plan/attribute_fields/suggest?content_type=${contentType}&category=${categoryLabel}`)
        .then(response => response.json())
        .then(data => {
          const existingFields = Array.from(categoryContainer.querySelectorAll('.field-label')).map(el => el.textContent.trim());
          const newFields = data.filter(f => !existingFields.includes(f));
          
          if (newFields.length > 0) {
            resultContainer.innerHTML = '';
            newFields.forEach(field => {
              const chip = document.createElement('span');
              chip.className = 'field-suggestion-link px-3 py-1 bg-gray-100 text-sm text-gray-800 rounded-full hover:bg-gray-200 cursor-pointer';
              chip.textContent = field;
              chip.addEventListener('click', function() {
                categoryContainer.querySelector('.js-field-input').value = field;
              });
              resultContainer.appendChild(chip);
            });
          } else {
            resultContainer.innerHTML = '<p class="text-sm text-gray-500">No suggestions available at the moment.</p>';
          }
        })
        .catch(error => {
          console.error('Error loading field suggestions:', error);
          resultContainer.innerHTML = '<p class="text-sm text-red-500">Failed to load suggestions. Please try again.</p>';
        });
      
      this.style.display = 'none';
    });
  });
});

// Initialize sortable functionality using jQuery UI
function initSortables() {
  if (typeof $ === 'undefined' || !$.fn.sortable) {
    console.error('jQuery UI Sortable not found');
    return;
  }
  
  // Categories sorting
  $('#categories-container').sortable({
    items: '.category-card',
    handle: '.category-drag-handle',
    placeholder: 'category-placeholder',
    cursor: 'move',
    opacity: 0.8,
    tolerance: 'pointer',
    update: function(event, ui) {
      const categoryId = ui.item.attr('data-category-id');
      const newPosition = ui.item.index();
      
      // AJAX request to update position using internal endpoint
      $.ajax({
        url: '/internal/sort/categories',
        type: 'PATCH',
        contentType: 'application/json',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        data: JSON.stringify({
          content_id: categoryId,
          intended_position: newPosition
        }),
        success: function(data) {
          console.log('Category position updated successfully:', data);
          if (data.message) {
            showNotification(data.message, 'success');
          }
          
          // Update the position field in the category config form if it's open
          updateCategoryConfigPosition(categoryId, data.category.position);
        },
        error: function(xhr, status, error) {
          console.error('Error updating category position:', error);
          showErrorMessage('Failed to reorder categories. Please try again.');
        }
      });
    }
  });
  
  // Fields sorting for each category
  $('.fields-container').sortable({
    items: '.field-item',
    handle: '.field-drag-handle',
    placeholder: 'field-placeholder',
    cursor: 'move',
    opacity: 0.8,
    tolerance: 'pointer',
    connectWith: '.fields-container',
    update: function(event, ui) {
      const fieldId = ui.item.attr('data-field-id');
      const newPosition = ui.item.index();
      const categoryId = ui.item.closest('.fields-container').attr('data-category-id');
      
      // AJAX request to update position using internal endpoint
      $.ajax({
        url: '/internal/sort/fields',
        type: 'PATCH',
        contentType: 'application/json',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        data: JSON.stringify({
          content_id: fieldId,
          intended_position: newPosition,
          attribute_category_id: categoryId
        }),
        success: function(data) {
          console.log('Field position updated successfully:', data);
          if (data.message) {
            showNotification(data.message, 'success');
          }
          
          // Update the position field in the field config form if it's open
          updateFieldConfigPosition(fieldId, data.field.position);
        },
        error: function(xhr, status, error) {
          console.error('Error updating field position:', error);
          showErrorMessage('Failed to reorder fields. Please try again.');
        }
      });
    }
  });
}

// Notification system
function showNotification(message, type = 'info') {
  const bgColor = type === 'success' ? 'bg-green-500' : type === 'error' ? 'bg-red-500' : 'bg-blue-500';
  const icon = type === 'success' ? 'check_circle' : type === 'error' ? 'error' : 'info';
  
  const notification = $(`
    <div class="fixed top-4 right-4 ${bgColor} text-white px-6 py-3 rounded-lg shadow-lg z-50 flex items-center animate-notification-in">
      <i class="material-icons text-sm mr-2">${icon}</i>
      <span class="text-sm font-medium">${message}</span>
      <button class="ml-4 text-white hover:text-gray-200" onclick="$(this).parent().remove()">
        <i class="material-icons text-sm">close</i>
      </button>
    </div>
  `);
  
  $('body').append(notification);
  
  // Auto-remove after 5 seconds
  setTimeout(() => {
    notification.fadeOut(300, function() {
      $(this).remove();
    });
  }, 5000);
}

// Make showNotification globally available
window.showNotification = showNotification;

// Category visibility toggle function
window.toggleCategoryVisibility = function(categoryId, isHidden) {
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  const button = categoryCard.querySelector('.category-visibility-toggle');
  
  fetch(`/plan/attribute_categories/${categoryId}`, {
    method: 'PUT',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      attribute_category: {
        hidden: !isHidden
      }
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success || data.message) {
      // Update the UI manually instead of reloading
      const newHiddenState = !isHidden;
      
      // Update button data attribute and title
      button.setAttribute('data-hidden', newHiddenState);
      button.setAttribute('title', newHiddenState ? 'Hidden category - Click to show' : 'Visible category - Click to hide');
      
      // Update the eye icon
      const eyeIcon = button.querySelector('svg');
      if (newHiddenState) {
        // Show closed eye icon
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"></path>';
      } else {
        // Show open eye icon
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>';
      }
      
      // Update category card styling
      if (newHiddenState) {
        categoryCard.classList.add('border-gray-300');
        categoryCard.style.borderColor = '';
        categoryCard.querySelector('.category-header').style.backgroundColor = '#f9fafb';
        categoryCard.querySelector('.category-icon i').classList.add('text-gray-400');
        categoryCard.querySelector('.category-icon i').style.color = '';
      } else {
        categoryCard.classList.remove('border-gray-300');
        const contentTypeColor = getComputedStyle(document.documentElement).getPropertyValue('--content-type-color') || '#6366f1';
        categoryCard.style.borderColor = contentTypeColor;
        categoryCard.querySelector('.category-header').style.backgroundColor = contentTypeColor + '20';
        categoryCard.querySelector('.category-icon i').classList.remove('text-gray-400');
        categoryCard.querySelector('.category-icon i').style.color = contentTypeColor;
      }
      
      // Update hidden status text
      const statusText = categoryCard.querySelector('.category-label').parentElement.querySelector('p');
      if (newHiddenState) {
        if (!statusText.textContent.includes('— Hidden')) {
          statusText.innerHTML += '<span class="text-gray-400 ml-2">— Hidden</span>';
        }
      } else {
        statusText.innerHTML = statusText.innerHTML.replace('<span class="text-gray-400 ml-2">— Hidden</span>', '');
      }
      
      showNotification(data.message, 'success');
    } else {
      showNotification('Failed to update category visibility', 'error');
    }
  })
  .catch(error => {
    console.error('Error toggling category visibility:', error);
    showNotification('Failed to update category visibility', 'error');
  });
};

// Field visibility toggle function
window.toggleFieldVisibility = function(fieldId, isHidden) {
  const fieldItem = document.querySelector(`[data-field-id="${fieldId}"]`);
  const button = fieldItem.querySelector('.field-visibility-toggle');
  
  fetch(`/plan/attribute_fields/${fieldId}`, {
    method: 'PUT',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      attribute_field: {
        hidden: !isHidden
      }
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success || data.message) {
      // Update the UI manually instead of reloading
      const newHiddenState = !isHidden;
      
      // Update button data attribute and title
      button.setAttribute('data-hidden', newHiddenState);
      button.setAttribute('title', newHiddenState ? 'Hidden field - Click to show' : 'Visible field - Click to hide');
      
      // Update the eye icon
      const eyeIcon = button.querySelector('svg');
      if (newHiddenState) {
        // Show closed eye icon
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"></path>';
      } else {
        // Show open eye icon
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>';
      }
      
      // Update field item styling
      if (newHiddenState) {
        fieldItem.classList.add('bg-gray-50', 'border-gray-200');
        fieldItem.classList.remove('bg-white');
        fieldItem.querySelector('.field-label').classList.add('text-gray-500');
        fieldItem.querySelector('.field-label').classList.remove('text-gray-800');
      } else {
        fieldItem.classList.remove('bg-gray-50', 'border-gray-200');
        fieldItem.classList.add('bg-white');
        fieldItem.querySelector('.field-label').classList.remove('text-gray-500');
        fieldItem.querySelector('.field-label').classList.add('text-gray-800');
      }
      
      // Update hidden status text in field info
      const fieldInfo = fieldItem.querySelector('.text-xs.text-gray-500');
      if (newHiddenState) {
        if (!fieldInfo.textContent.includes('— Hidden')) {
          fieldInfo.innerHTML += '<span class="ml-1.5 text-gray-400">— Hidden</span>';
        }
      } else {
        fieldInfo.innerHTML = fieldInfo.innerHTML.replace('<span class="ml-1.5 text-gray-400">— Hidden</span>', '');
      }
      
      showNotification(data.message, 'success');
    } else {
      showNotification('Failed to update field visibility', 'error');
    }
  })
  .catch(error => {
    console.error('Error toggling field visibility:', error);
    showNotification('Failed to update field visibility', 'error');
  });
};

// Category icon preview function
window.updateCategoryIconPreview = function(categoryId, iconName) {
  // Update the icon preview in the category header
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  if (categoryCard) {
    const iconElement = categoryCard.querySelector('.category-icon i');
    if (iconElement) {
      iconElement.textContent = iconName;
    }
  }
  
  // Update the form to show the selected icon
  const iconPreview = document.getElementById('selected-icon-preview');
  if (iconPreview) {
    iconPreview.textContent = iconName;
  }
};

// Function to show error messages to users (legacy compatibility)
function showErrorMessage(message) {
  showNotification(message, 'error');
}

// Bind remote form handlers to dynamically loaded forms in a container
function bindRemoteFormsInContainer(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  // Find all forms with remote: true in the container
  const remoteForms = container.querySelectorAll('form[data-remote="true"]');
  
  remoteForms.forEach(form => {
    // Remove any existing event listeners to prevent duplicates
    form.removeEventListener('submit', handleRemoteFormSubmit);
    
    // Add our custom submit handler
    form.addEventListener('submit', handleRemoteFormSubmit);
  });
}

// Handle remote form submission manually
function handleRemoteFormSubmit(event) {
  event.preventDefault(); // Prevent default form submission
  
  const form = event.target;
  const formData = new FormData(form);
  const submitButton = form.querySelector('input[type="submit"], button[type="submit"]');
  let originalText = '';
  
  // Disable submit button to prevent double submission
  if (submitButton) {
    submitButton.disabled = true;
    originalText = submitButton.value || submitButton.textContent;
    if (submitButton.tagName === 'INPUT') {
      submitButton.value = 'Saving...';
    } else {
      submitButton.textContent = 'Saving...';
    }
    
    // Restore button after 3 seconds as fallback
    setTimeout(() => {
      submitButton.disabled = false;
      if (submitButton.tagName === 'INPUT') {
        submitButton.value = originalText;
      } else {
        submitButton.textContent = originalText;
      }
    }, 3000);
  }
  
  // Convert FormData to JSON for Rails
  const jsonData = {};
  for (let [key, value] of formData.entries()) {
    // Skip Rails form helper fields
    if (key === 'utf8' || key === '_method' || key === 'authenticity_token') {
      continue;
    }
    
    // Handle nested attributes properly - support multiple levels
    if (key.includes('[') && key.includes(']')) {
      // Parse nested field names like attribute_field[field_options][input_size]
      const keyParts = key.split(/[\[\]]+/).filter(part => part !== '');
      
      let current = jsonData;
      for (let i = 0; i < keyParts.length - 1; i++) {
        const part = keyParts[i];
        if (!current[part]) {
          current[part] = {};
        }
        current = current[part];
      }
      
      const finalKey = keyParts[keyParts.length - 1];
      current[finalKey] = value;
    } else {
      jsonData[key] = value;
    }
  }
  
  console.log('Converted form data:', jsonData);
  
  // Get the actual HTTP method from Rails form
  let httpMethod = form.method.toUpperCase();
  
  // Check for Rails method override (for PUT/PATCH/DELETE)
  const methodInput = form.querySelector('input[name="_method"]');
  if (methodInput) {
    httpMethod = methodInput.value.toUpperCase();
  }
  
  console.log('Submitting form with method:', httpMethod, 'to:', form.action);
  
  // Submit form via fetch
  fetch(form.action, {
    method: httpMethod,
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(jsonData)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response.json();
  })
  .then(data => {
    console.log('Form submitted successfully:', data);
    
    // Re-enable submit button
    if (submitButton) {
      submitButton.disabled = false;
      if (submitButton.tagName === 'INPUT') {
        submitButton.value = originalText;
      } else {
        submitButton.textContent = originalText;
      }
    }
    
    // Show success notification
    if (data.message) {
      showNotification(data.message, 'success');
    }
    
    // Handle category form updates
    if (form.action.includes('/attribute_categories/')) {
      handleCategoryFormSuccess(form, data);
    }
    
    // Handle field form updates  
    if (form.action.includes('/attribute_fields/')) {
      handleFieldFormSuccess(form, data);
    }
  })
  .catch(error => {
    console.error('Form submission failed:', error);
    
    // Re-enable submit button
    if (submitButton) {
      submitButton.disabled = false;
      if (submitButton.tagName === 'INPUT') {
        submitButton.value = originalText;  
      } else {
        submitButton.textContent = originalText;
      }
    }
    
    showNotification('Failed to save changes', 'error');
  });
}

// Setup remote form handlers for dynamically loaded forms
function setupRemoteFormHandlers() {
  // Handle successful form submissions (backup for Rails UJS if it works)
  document.addEventListener('ajax:success', function(event) {
    const form = event.target;
    if (!form.matches('form[data-remote="true"]')) return;
    
    const response = event.detail[0];
    console.log('Form submitted successfully via Rails UJS:', response);
    
    // Show success notification
    if (response.message) {
      showNotification(response.message, 'success');
    }
    
    // Handle category form updates
    if (form.action.includes('/attribute_categories/')) {
      handleCategoryFormSuccess(form, response);
    }
    
    // Handle field form updates  
    if (form.action.includes('/attribute_fields/')) {
      handleFieldFormSuccess(form, response);
    }
  });
  
  // Handle form submission errors (backup for Rails UJS if it works)
  document.addEventListener('ajax:error', function(event) {
    const form = event.target;
    if (!form.matches('form[data-remote="true"]')) return;
    
    const response = event.detail[0];
    console.error('Form submission failed via Rails UJS:', response);
    
    let errorMessage = 'Failed to save changes';
    if (response && response.error) {
      errorMessage = response.error;
    }
    
    showNotification(errorMessage, 'error');
  });
}

// Handle successful category form submission
function handleCategoryFormSuccess(form, response) {
  // Check if this is a new category creation (POST to /attribute_categories)
  const isNewCategory = form.method.toUpperCase() === 'POST' && form.action.endsWith('/attribute_categories');
  
  if (isNewCategory) {
    // Handle new category creation
    if (response.category) {
      addNewCategoryToUI(response.category, response.rendered_html);
      
      // Hide the add category form and reset it
      const addCategoryForm = document.getElementById('add-category-form');
      if (addCategoryForm) {
        addCategoryForm.classList.add('hidden');
        form.reset();
      }
    }
    return;
  }
  
  // Handle existing category updates
  const matches = form.action.match(/\/attribute_categories\/(\d+)/);
  if (!matches) return;
  
  const categoryId = matches[1];
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  if (!categoryCard) return;
  
  // Update category display if label changed
  if (response.category && response.category.label) {
    const labelElement = categoryCard.querySelector('.category-label');
    if (labelElement) {
      labelElement.textContent = response.category.label;
    }
  }
  
  // Update category icon if changed
  if (response.category && response.category.icon) {
    const iconElement = categoryCard.querySelector('.category-icon i');
    if (iconElement) {
      iconElement.textContent = response.category.icon;
    }
  }
  
  // Handle archive/visibility changes
  if (response.category && typeof response.category.hidden !== 'undefined') {
    const isArchived = response.category.hidden;
    updateCategoryArchiveUI(categoryId, isArchived);
    updateArchivedItemsCount();
    
    // Auto-enable "Show archived items" when archiving from config panel
    if (isArchived) {
      const alpineElement = document.querySelector('[x-data*="showArchived"]');
      if (alpineElement && alpineElement._x_dataStack) {
        const alpine = alpineElement._x_dataStack[0];
        if (alpine && !alpine.showArchived) {
          alpine.showArchived = true;
          toggleArchivedItems(true);
        }
      }
    }
    
    // Reload the configuration panel to show the updated archive state
    reloadCategoryConfiguration(categoryId);
  }
}

// Reload category configuration panel to reflect updated state
function reloadCategoryConfiguration(categoryId) {
  // Only reload if this category's configuration is currently open
  const alpineElement = document.querySelector('.attributes-editor');
  if (alpineElement && alpineElement._x_dataStack) {
    const alpine = alpineElement._x_dataStack[0];
    
    if (alpine && alpine.selectedCategory == categoryId) {
      console.log(`Reloading configuration for category ${categoryId}`);
      
      // Show loading animation
      showConfigLoadingAnimation('category-config-container');
      
      // Reload category configuration via AJAX
      fetch(`/plan/attribute_categories/${categoryId}/edit`)
        .then(response => response.text())
        .then(html => {
          document.getElementById('category-config-container').innerHTML = html;
          // Bind remote form handlers to newly loaded forms
          bindRemoteFormsInContainer('category-config-container');
          // Hide loading animation
          hideConfigLoadingAnimation('category-config-container');
        })
        .catch(error => {
          console.error('Error reloading category config:', error);
          hideConfigLoadingAnimation('category-config-container');
          showNotification('Failed to reload category configuration', 'error');
        });
    }
  }
}

// Add new field to the UI using server-rendered HTML
function addNewFieldToUI(field, renderedHtml, form) {
  // Find the fields container for the category this field belongs to
  const categoryId = field.attribute_category_id;
  const fieldsContainer = document.querySelector(`.fields-container[data-category-id="${categoryId}"]`);
  
  if (!fieldsContainer) {
    console.error(`Fields container not found for category ${categoryId}`);
    return;
  }
  
  // If we have rendered HTML from the server, use that
  if (renderedHtml) {
    // Add the new field to the fields container
    fieldsContainer.insertAdjacentHTML('beforeend', renderedHtml);
    
    // Update the category field count in the header
    updateCategoryFieldCount(categoryId);
    
    console.log(`Added new field "${field.label}" to category ${categoryId} using server-rendered HTML`);
    return;
  }
  
  // Fallback: If no rendered HTML provided, log error and skip
  console.error('No rendered HTML provided for new field. Field not added to UI.');
}

// Update category field count in the header
function updateCategoryFieldCount(categoryId) {
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  if (!categoryCard) return;
  
  const fieldsContainer = categoryCard.querySelector(`.fields-container[data-category-id="${categoryId}"]`);
  if (!fieldsContainer) return;
  
  // Count visible fields (excluding archived ones if they're hidden)
  const fieldItems = fieldsContainer.querySelectorAll('.field-item');
  const visibleFields = Array.from(fieldItems).filter(field => 
    field.style.display !== 'none'
  );
  
  // Update the count in the category header
  const fieldCountElement = categoryCard.querySelector('.category-label').parentElement.querySelector('p');
  if (fieldCountElement) {
    const count = visibleFields.length;
    const fieldText = count === 1 ? 'field' : 'fields';
    
    // Update just the count part, preserving any status text (like "— Archived")
    const statusMatch = fieldCountElement.innerHTML.match(/<span[^>]*>.*?<\/span>/);
    const statusText = statusMatch ? statusMatch[0] : '';
    fieldCountElement.innerHTML = `${count} ${fieldText}${statusText ? ' ' + statusText : ''}`;
  }
}

// Add new category to the UI using server-rendered HTML
function addNewCategoryToUI(category, renderedHtml) {
  const categoriesContainer = document.getElementById('categories-container');
  if (!categoriesContainer) return;
  
  // If we have rendered HTML from the server, use that instead of generating our own
  if (renderedHtml) {
    // Find the "Add Category" card and insert the new category before it
    const addCategoryCard = categoriesContainer.querySelector('.bg-white.rounded-lg.shadow-sm.border.border-dashed');
    if (addCategoryCard) {
      addCategoryCard.insertAdjacentHTML('beforebegin', renderedHtml);
    } else {
      // Fallback: add to the end of the container
      categoriesContainer.insertAdjacentHTML('beforeend', renderedHtml);
    }
    
    console.log(`Added new category "${category.label}" to UI using server-rendered HTML`);
    return;
  }
  
  // Fallback: If no rendered HTML provided, log error and skip
  console.error('No rendered HTML provided for new category. Category not added to UI.');
}

// Handle new field form submission manually
window.submitFieldForm = function(event) {
  const form = event.target;
  const submitButton = form.querySelector('input[type="submit"], button[type="submit"]');
  
  // Disable submit button and show loading state
  let originalText = '';
  if (submitButton) {
    submitButton.disabled = true;
    originalText = submitButton.value || submitButton.textContent;
    if (submitButton.tagName === 'INPUT') {
      submitButton.value = 'Creating...';
    } else {
      submitButton.textContent = 'Creating...';
    }
  }
  
  // Convert form data to JSON
  const formData = new FormData(form);
  const jsonData = {};
  
  for (let [key, value] of formData.entries()) {
    // Skip Rails form helper fields
    if (key === 'utf8' || key === '_method' || key === 'authenticity_token') {
      continue;
    }
    
    // Handle nested attributes properly
    if (key.includes('[') && key.includes(']')) {
      const keyParts = key.split(/[\[\]]+/).filter(part => part !== '');
      let current = jsonData;
      for (let i = 0; i < keyParts.length - 1; i++) {
        const part = keyParts[i];
        if (!current[part]) {
          current[part] = {};
        }
        current = current[part];
      }
      const finalKey = keyParts[keyParts.length - 1];
      
      // Handle checkbox arrays (like linkable_types)
      if (form.querySelectorAll(`[name="${key}"]`).length > 1) {
        if (!current[finalKey]) {
          current[finalKey] = [];
        }
        if (value !== '') {
          current[finalKey].push(value);
        }
      } else {
        current[finalKey] = value;
      }
    } else {
      jsonData[key] = value;
    }
  }
  
  console.log('Submitting new field form:', jsonData);
  
  // Submit form via fetch
  fetch(form.action, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(jsonData)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response.json();
  })
  .then(data => {
    console.log('Field created successfully:', data);
    
    // Handle success
    if (data.field && data.html) {
      addNewFieldToUI(data.field, data.html, form);
      
      // Reset the form and close the add field section
      form.reset();
      const addingFieldSection = form.closest('[x-data*="addingField"]');
      if (addingFieldSection) {
        // Use Alpine.js to close the form
        const alpineData = Alpine.$data(addingFieldSection);
        if (alpineData) {
          alpineData.addingField = false;
        }
      }
      
      // Show success notification
      if (data.message) {
        showNotification(data.message, 'success');
      } else {
        showNotification(`Field "${data.field.label}" created successfully`, 'success');
      }
    }
  })
  .catch(error => {
    console.error('Failed to create field:', error);
    showNotification('Failed to create field', 'error');
  })
  .finally(() => {
    // Re-enable submit button
    if (submitButton) {
      submitButton.disabled = false;
      if (submitButton.tagName === 'INPUT') {
        submitButton.value = originalText;
      } else {
        submitButton.textContent = originalText;
      }
    }
  });
};

// Handle new category form submission manually
window.submitCategoryForm = function(event) {
  const form = event.target;
  const submitButton = form.querySelector('input[type="submit"], button[type="submit"]');
  
  // Disable submit button and show loading state
  let originalText = '';
  if (submitButton) {
    submitButton.disabled = true;
    originalText = submitButton.value || submitButton.textContent;
    if (submitButton.tagName === 'INPUT') {
      submitButton.value = 'Creating...';
    } else {
      submitButton.textContent = 'Creating...';
    }
  }
  
  // Convert form data to JSON
  const formData = new FormData(form);
  const jsonData = {};
  
  for (let [key, value] of formData.entries()) {
    // Skip Rails form helper fields
    if (key === 'utf8' || key === '_method' || key === 'authenticity_token') {
      continue;
    }
    
    // Handle nested attributes properly
    if (key.includes('[') && key.includes(']')) {
      const keyParts = key.split(/[\[\]]+/).filter(part => part !== '');
      let current = jsonData;
      for (let i = 0; i < keyParts.length - 1; i++) {
        const part = keyParts[i];
        if (!current[part]) {
          current[part] = {};
        }
        current = current[part];
      }
      const finalKey = keyParts[keyParts.length - 1];
      current[finalKey] = value;
    } else {
      jsonData[key] = value;
    }
  }
  
  console.log('Submitting new category form:', jsonData);
  
  // Submit form via fetch
  fetch(form.action, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(jsonData)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response.json();
  })
  .then(data => {
    console.log('Category created successfully:', data);
    
    // Handle success
    if (data.category) {
      addNewCategoryToUI(data.category, data.rendered_html);
      
      // Hide the form and reset it
      document.getElementById('add-category-form').classList.add('hidden');
      form.reset();
      
      // Show success notification
      if (data.message) {
        showNotification(data.message, 'success');
      } else {
        showNotification(`Category "${data.category.label}" created successfully`, 'success');
      }
    }
  })
  .catch(error => {
    console.error('Failed to create category:', error);
    showNotification('Failed to create category', 'error');
  })
  .finally(() => {
    // Re-enable submit button
    if (submitButton) {
      submitButton.disabled = false;
      if (submitButton.tagName === 'INPUT') {
        submitButton.value = originalText;
      } else {
        submitButton.textContent = originalText;
      }
    }
  });
};

// Handle successful field form submission
function handleFieldFormSuccess(form, response) {
  // Check if this is a new field creation (POST to /attribute_fields)
  const isNewField = form.method.toUpperCase() === 'POST' && form.action.endsWith('/attribute_fields');
  
  if (isNewField) {
    // Handle new field creation
    if (response.field && response.html) {
      addNewFieldToUI(response.field, response.html, form);
      
      // Reset the form and close the add field section
      form.reset();
      const addingFieldSection = form.closest('[x-data*="addingField"]');
      if (addingFieldSection) {
        // Use Alpine.js to close the form
        const alpineData = Alpine.$data(addingFieldSection);
        if (alpineData) {
          alpineData.addingField = false;
        }
      }
    }
    return;
  }
  
  // Handle existing field updates
  const matches = form.action.match(/\/attribute_fields\/(\d+)/);
  if (!matches) return;
  
  const fieldId = matches[1];
  const fieldItem = document.querySelector(`[data-field-id="${fieldId}"]`);
  if (!fieldItem) return;
  
  // Update field display if label changed
  if (response.field && response.field.label) {
    const labelElement = fieldItem.querySelector('.field-label');
    if (labelElement) {
      labelElement.textContent = response.field.label;
    }
  }
  
  // Handle visibility changes
  if (response.field && typeof response.field.hidden !== 'undefined') {
    const isHidden = response.field.hidden;
    updateFieldVisibilityUI(fieldId, isHidden);
  }
}

// Update category visibility UI elements
function updateCategoryVisibilityUI(categoryId, isHidden) {
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  if (!categoryCard) return;
  
  // Update visibility toggle button
  const button = categoryCard.querySelector('.category-visibility-toggle');
  if (button) {
    button.setAttribute('data-hidden', isHidden);
    button.setAttribute('title', isHidden ? 'Hidden category - Click to show' : 'Visible category - Click to hide');
    
    const eyeIcon = button.querySelector('svg');
    if (eyeIcon) {
      if (isHidden) {
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"></path>';
      } else {
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>';
      }
    }
  }
  
  // Update category card styling
  if (isHidden) {
    categoryCard.classList.add('border-gray-300');
    categoryCard.style.borderColor = '';
    categoryCard.querySelector('.category-header').style.backgroundColor = '#f9fafb';
    categoryCard.querySelector('.category-icon i').classList.add('text-gray-400');
    categoryCard.querySelector('.category-icon i').style.color = '';
  } else {
    categoryCard.classList.remove('border-gray-300');
    const contentTypeColor = getComputedStyle(document.documentElement).getPropertyValue('--content-type-color') || '#6366f1';
    categoryCard.style.borderColor = contentTypeColor;
    categoryCard.querySelector('.category-header').style.backgroundColor = contentTypeColor + '20';
    categoryCard.querySelector('.category-icon i').classList.remove('text-gray-400');
    categoryCard.querySelector('.category-icon i').style.color = contentTypeColor;
  }
  
  // Update hidden status text
  const statusText = categoryCard.querySelector('.category-label').parentElement.querySelector('p');
  if (statusText) {
    if (isHidden) {
      if (!statusText.textContent.includes('— Hidden')) {
        statusText.innerHTML += '<span class="text-gray-400 ml-2">— Hidden</span>';
      }
    } else {
      statusText.innerHTML = statusText.innerHTML.replace('<span class="text-gray-400 ml-2">— Hidden</span>', '');
    }
  }
}

// Update field visibility UI elements
function updateFieldVisibilityUI(fieldId, isHidden) {
  const fieldItem = document.querySelector(`[data-field-id="${fieldId}"]`);
  if (!fieldItem) return;
  
  // Update visibility toggle button
  const button = fieldItem.querySelector('.field-visibility-toggle');
  if (button) {
    button.setAttribute('data-hidden', isHidden);
    button.setAttribute('title', isHidden ? 'Hidden field - Click to show' : 'Visible field - Click to hide');
    
    const eyeIcon = button.querySelector('svg');
    if (eyeIcon) {
      if (isHidden) {
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"></path>';
      } else {
        eyeIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>';
      }
    }
  }
  
  // Update field item styling
  if (isHidden) {
    fieldItem.classList.add('bg-gray-50', 'border-gray-200');
    fieldItem.classList.remove('bg-white');
    fieldItem.querySelector('.field-label').classList.add('text-gray-500');
    fieldItem.querySelector('.field-label').classList.remove('text-gray-800');
  } else {
    fieldItem.classList.remove('bg-gray-50', 'border-gray-200');
    fieldItem.classList.add('bg-white');
    fieldItem.querySelector('.field-label').classList.remove('text-gray-500');
    fieldItem.querySelector('.field-label').classList.add('text-gray-800');
  }
  
  // Update hidden status text
  const fieldInfo = fieldItem.querySelector('.text-xs.text-gray-500');
  if (fieldInfo) {
    if (isHidden) {
      if (!fieldInfo.textContent.includes('— Hidden')) {
        fieldInfo.innerHTML += '<span class="ml-1.5 text-gray-400">— Hidden</span>';
      }
    } else {
      fieldInfo.innerHTML = fieldInfo.innerHTML.replace('<span class="ml-1.5 text-gray-400">— Hidden</span>', '');
    }
  }
}

// Update category configuration form position field after drag and drop
function updateCategoryConfigPosition(categoryId, newPosition) {
  // Check if the category config form is currently open
  const alpineElement = document.querySelector('.attributes-editor');
  if (alpineElement && alpineElement._x_dataStack) {
    const alpine = alpineElement._x_dataStack[0];
    
    // Only update if this category's config form is currently open
    if (alpine.selectedCategory == categoryId) {
      const categoryConfigContainer = document.getElementById('category-config-container');
      if (categoryConfigContainer) {
        const positionInput = categoryConfigContainer.querySelector('input[name="attribute_category[position]"]');
        if (positionInput) {
          console.log(`Updating category ${categoryId} position input from ${positionInput.value} to ${newPosition}`);
          positionInput.value = newPosition;
        }
      }
    }
  }
}

// Update field configuration form position field after drag and drop
function updateFieldConfigPosition(fieldId, newPosition) {
  // Check if the field config form is currently open
  const alpineElement = document.querySelector('.attributes-editor');
  if (alpineElement && alpineElement._x_dataStack) {
    const alpine = alpineElement._x_dataStack[0];
    
    // Only update if this field's config form is currently open
    if (alpine.selectedField == fieldId) {
      const fieldConfigContainer = document.getElementById('field-config-container');
      if (fieldConfigContainer) {
        const positionInput = fieldConfigContainer.querySelector('input[name="attribute_field[position]"]');
        if (positionInput) {
          console.log(`Updating field ${fieldId} position input from ${positionInput.value} to ${newPosition}`);
          positionInput.value = newPosition;
        }
      }
    }
  }
}

// Show loading animation for configuration panels
function showConfigLoadingAnimation(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  // Create loading bar element
  const loadingBar = document.createElement('div');
  loadingBar.className = 'config-loading-bar';
  loadingBar.innerHTML = `
    <div class="loading-bar-container">
      <div class="loading-bar-progress"></div>
    </div>
    <div class="loading-content">
      <div class="animate-pulse">
        <div class="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
        <div class="space-y-3">
          <div class="h-3 bg-gray-200 rounded w-3/4"></div>
          <div class="h-3 bg-gray-200 rounded w-1/2"></div>
          <div class="h-3 bg-gray-200 rounded w-5/6"></div>
        </div>
      </div>
    </div>
  `;
  
  // Add loading styles
  const style = document.createElement('style');
  style.textContent = `
    .config-loading-bar {
      position: relative;
      padding: 1rem;
    }
    
    .loading-bar-container {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 3px;
      background-color: #f3f4f6;
      overflow: hidden;
    }
    
    .loading-bar-progress {
      height: 100%;
      background: linear-gradient(90deg, var(--content-type-color, #6366f1) 0%, rgba(99, 102, 241, 0.6) 50%, var(--content-type-color, #6366f1) 100%);
      background-size: 200% 100%;
      animation: loading-slide 1.5s ease-in-out infinite;
    }
    
    @keyframes loading-slide {
      0% {
        transform: translateX(-100%);
      }
      100% {
        transform: translateX(100%);
      }
    }
    
    .loading-content {
      margin-top: 1rem;
    }
  `;
  
  // Add styles to head if not already present
  if (!document.querySelector('.config-loading-styles')) {
    style.classList.add('config-loading-styles');
    document.head.appendChild(style);
  }
  
  // Replace container content with loading animation
  container.innerHTML = '';
  container.appendChild(loadingBar);
}

// Hide loading animation for configuration panels
function hideConfigLoadingAnimation(containerId) {
  // The loading animation will be replaced when the actual content loads
  // This function is called after the content is set, so it's mainly for cleanup
  // and error handling scenarios
  
  // Remove any loading-specific styles or elements if needed
  const container = document.getElementById(containerId);
  if (container) {
    const loadingBar = container.querySelector('.config-loading-bar');
    if (loadingBar) {
      loadingBar.remove();
    }
  }
}

// Show loading animation for suggestions containers
function showSuggestionsLoadingAnimation(container) {
  if (!container) return;
  
  // Create compact loading indicator for suggestions
  const loadingIndicator = document.createElement('div');
  loadingIndicator.className = 'suggestions-loading-indicator';
  loadingIndicator.innerHTML = `
    <div class="loading-bar-container">
      <div class="loading-bar-progress"></div>
    </div>
    <div class="loading-content">
      <div class="loading-dots">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div>
      <span class="loading-text">Loading suggestions...</span>
    </div>
  `;
  
  // Add suggestion loading styles if not already present
  if (!document.querySelector('.suggestions-loading-styles')) {
    const style = document.createElement('style');
    style.classList.add('suggestions-loading-styles');
    style.textContent = `
      .suggestions-loading-indicator {
        position: relative;
        border: 1px solid #e5e7eb;
        border-radius: 0.375rem;
        background-color: #f9fafb;
        margin: 0.5rem 0;
        padding: 0.75rem;
      }
      
      .suggestions-loading-indicator .loading-bar-container {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 2px;
        background-color: #f3f4f6;
        overflow: hidden;
        border-radius: 0.375rem 0.375rem 0 0;
      }
      
      .suggestions-loading-indicator .loading-bar-progress {
        height: 100%;
        background: linear-gradient(90deg, var(--content-type-color, #6366f1) 0%, rgba(99, 102, 241, 0.6) 50%, var(--content-type-color, #6366f1) 100%);
        background-size: 200% 100%;
        animation: loading-slide 1.2s ease-in-out infinite;
      }
      
      .suggestions-loading-indicator .loading-content {
        display: flex;
        align-items: center;
        justify-content: center;
        padding-top: 0.25rem;
      }
      
      .suggestions-loading-indicator .loading-dots {
        display: flex;
        align-items: center;
        margin-right: 0.5rem;
      }
      
      .suggestions-loading-indicator .loading-dots .dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background-color: #9ca3af;
        margin: 0 2px;
        animation: loading-dots 1.4s ease-in-out infinite both;
      }
      
      .suggestions-loading-indicator .loading-dots .dot:nth-child(1) {
        animation-delay: -0.32s;
      }
      
      .suggestions-loading-indicator .loading-dots .dot:nth-child(2) {
        animation-delay: -0.16s;
      }
      
      .suggestions-loading-indicator .loading-text {
        font-size: 0.875rem;
        color: #6b7280;
        font-weight: 500;
      }
      
      @keyframes loading-dots {
        0%, 80%, 100% {
          transform: scale(0.8);
          opacity: 0.5;
        }
        40% {
          transform: scale(1);
          opacity: 1;
        }
      }
    `;
    document.head.appendChild(style);
  }
  
  // Replace container content with loading animation
  container.innerHTML = '';
  container.appendChild(loadingIndicator);
}

// Archive/restore functionality for fields
window.toggleFieldArchive = function(fieldId, isArchived) {
  const fieldItem = document.querySelector(`[data-field-id="${fieldId}"]`);
  const button = fieldItem.querySelector('.field-archive-toggle');
  
  // Show loading state
  const originalIcon = button.innerHTML;
  button.innerHTML = '<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-400"></div>';
  button.disabled = true;
  
  fetch(`/plan/attribute_fields/${fieldId}`, {
    method: 'PUT',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      attribute_field: {
        hidden: !isArchived
      }
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success || data.message) {
      const newArchivedState = !isArchived;
      updateFieldArchiveUI(fieldId, newArchivedState);
      updateArchivedItemsCount();
      
      // Auto-enable "Show archived items" when archiving
      if (newArchivedState) {
        const alpineElement = document.querySelector('[x-data*="showArchived"]');
        if (alpineElement && alpineElement._x_dataStack) {
          const alpine = alpineElement._x_dataStack[0];
          if (alpine && !alpine.showArchived) {
            alpine.showArchived = true;
            toggleArchivedItems(true);
          }
        }
      }
      
      const action = newArchivedState ? 'archived' : 'restored';
      showNotification(`Field ${action} successfully`, 'success');
    } else {
      // Restore original state on error
      button.innerHTML = originalIcon;
      button.disabled = false;
      showNotification('Failed to update field archive status', 'error');
    }
  })
  .catch(error => {
    console.error('Error toggling field archive:', error);
    // Restore original state on error
    button.innerHTML = originalIcon;
    button.disabled = false;
    showNotification('Failed to update field archive status', 'error');
  });
};

// Archive/restore functionality for categories  
window.toggleCategoryArchive = function(categoryId, isArchived) {
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  const button = categoryCard.querySelector('.category-archive-toggle');
  
  // Show loading state
  const originalIcon = button.innerHTML;
  button.innerHTML = '<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-400"></div>';
  button.disabled = true;
  
  fetch(`/plan/attribute_categories/${categoryId}`, {
    method: 'PUT',
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      attribute_category: {
        hidden: !isArchived
      }
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success || data.message) {
      const newArchivedState = !isArchived;
      
      // If archiving a category, close its configuration panel if it's currently open
      if (newArchivedState) {
        const alpineElement = document.querySelector('.attributes-editor');
        if (alpineElement && alpineElement._x_dataStack) {
          const alpine = alpineElement._x_dataStack[0];
          if (alpine && alpine.selectedCategory == categoryId) {
            // Deselect the category and close configuration panel
            alpine.selectedCategory = null;
            alpine.configuring = false;
            console.log(`Closed configuration panel for archived category ${categoryId}`);
          }
        }
      }
      
      updateCategoryArchiveUI(categoryId, newArchivedState);
      updateArchivedItemsCount();
      
      // Auto-enable "Show archived items" when archiving
      if (newArchivedState) {
        const alpineElement = document.querySelector('[x-data*="showArchived"]');
        if (alpineElement && alpineElement._x_dataStack) {
          const alpine = alpineElement._x_dataStack[0];
          if (alpine && !alpine.showArchived) {
            alpine.showArchived = true;
            toggleArchivedItems(true);
          }
        }
      }
      
      const action = newArchivedState ? 'archived' : 'restored';
      showNotification(`Category ${action} successfully`, 'success');
    } else {
      // Restore original state on error
      button.innerHTML = originalIcon;
      button.disabled = false;
      showNotification('Failed to update category archive status', 'error');
    }
  })
  .catch(error => {
    console.error('Error toggling category archive:', error);
    // Restore original state on error
    button.innerHTML = originalIcon;
    button.disabled = false;
    showNotification('Failed to update category archive status', 'error');
  });
};

// Toggle show/hide archived items (categories and fields)
window.toggleArchivedItems = function(show) {
  const archivedFields = document.querySelectorAll('.field-item[data-archived="true"]');
  const archivedCategories = document.querySelectorAll('.category-card[data-archived="true"]');
  
  archivedFields.forEach(field => {
    if (show) {
      field.style.display = '';
      field.classList.add('archived-field');
    } else {
      field.style.display = 'none';
      field.classList.remove('archived-field');
    }
  });
  
  archivedCategories.forEach(category => {
    if (show) {
      category.style.display = '';
      category.classList.add('archived-category');
    } else {
      category.style.display = 'none';
      category.classList.remove('archived-category');
    }
  });
  
  // Show first-time user tip if showing archived items for the first time
  if (show && !localStorage.getItem('seen_archive_tip')) {
    showArchiveTip();
    localStorage.setItem('seen_archive_tip', 'true');
  }
};

// Update field archive UI elements
function updateFieldArchiveUI(fieldId, isArchived) {
  const fieldItem = document.querySelector(`[data-field-id="${fieldId}"]`);
  if (!fieldItem) return;
  
  // Update data attribute
  fieldItem.setAttribute('data-archived', isArchived);
  
  // Update archive toggle button
  const button = fieldItem.querySelector('.field-archive-toggle');
  if (button) {
    button.setAttribute('data-archived', isArchived);
    button.setAttribute('title', isArchived ? 'Archived field - Click to restore' : 'Active field - Click to archive');
    button.disabled = false; // Re-enable button after successful update
    
    // Update button content with correct icon
    if (isArchived) {
      button.innerHTML = '<i class="material-icons text-amber-600 text-sm">unarchive</i>';
    } else {
      button.innerHTML = '<i class="material-icons text-gray-500 text-sm">archive</i>';
    }
  }
  
  // Update field item styling
  if (isArchived) {
    fieldItem.classList.add('bg-gray-100', 'border-gray-300', 'opacity-60', 'archived-field');
    fieldItem.classList.remove('bg-white');
    fieldItem.querySelector('.field-label').classList.add('text-gray-500');
    fieldItem.querySelector('.field-label').classList.remove('text-gray-800');
    
    // Add archive icon to label if not present
    const label = fieldItem.querySelector('.field-label');
    if (!label.querySelector('.material-icons')) {
      label.innerHTML += '<i class="material-icons text-amber-600 text-sm ml-1.5 align-middle">archive</i>';
    }
  } else {
    fieldItem.classList.remove('bg-gray-100', 'border-gray-300', 'opacity-60', 'archived-field');
    fieldItem.classList.add('bg-white');
    fieldItem.querySelector('.field-label').classList.remove('text-gray-500');
    fieldItem.querySelector('.field-label').classList.add('text-gray-800');
    
    // Remove archive icon from label
    const archiveIcon = fieldItem.querySelector('.field-label .material-icons');
    if (archiveIcon) {
      archiveIcon.remove();
    }
  }
  
  // Update archive status text
  const fieldInfo = fieldItem.querySelector('.text-xs.text-gray-500');
  if (fieldInfo) {
    // Remove existing status spans
    fieldInfo.querySelectorAll('span').forEach(span => {
      if (span.textContent.includes('Hidden') || span.textContent.includes('Archived')) {
        span.remove();
      }
    });
    
    // Add archived status if needed
    if (isArchived) {
      const archivedSpan = document.createElement('span');
      archivedSpan.className = 'ml-1.5 text-amber-600';
      archivedSpan.textContent = '— Archived';
      fieldInfo.appendChild(archivedSpan);
    }
  }
  
  // Hide archived field if show archived is off
  const showArchivedToggle = document.querySelector('input[x-model="showArchived"]');
  if (showArchivedToggle && !showArchivedToggle.checked && isArchived) {
    fieldItem.style.display = 'none';
  } else if (!isArchived) {
    fieldItem.style.display = '';
  }
}

// Update category archive UI elements
function updateCategoryArchiveUI(categoryId, isArchived) {
  const categoryCard = document.querySelector(`[data-category-id="${categoryId}"]`);
  if (!categoryCard) return;
  
  // Update data attribute
  categoryCard.setAttribute('data-archived', isArchived);
  
  // Update archive button data attribute and title
  const archiveButton = categoryCard.querySelector('.category-archive-toggle');
  if (archiveButton) {
    archiveButton.setAttribute('data-archived', isArchived);
    archiveButton.setAttribute('title', isArchived ? 'Archived category - Click to restore' : 'Active category - Click to archive');
    archiveButton.disabled = false; // Re-enable button after successful update
    
    // Update the button icon
    if (isArchived) {
      archiveButton.innerHTML = '<i class="material-icons text-amber-600 text-sm">unarchive</i>';
    } else {
      archiveButton.innerHTML = '<i class="material-icons text-gray-500 text-sm">archive</i>';
    }
  }
  
  // Update category styling and archive icon
  if (isArchived) {
    categoryCard.classList.add('border-gray-300', 'opacity-60', 'archived-category');
    categoryCard.style.borderColor = '';
    categoryCard.querySelector('.category-header').style.backgroundColor = '#f3f4f6';
    categoryCard.querySelector('.category-icon i').classList.add('text-gray-400');
    categoryCard.querySelector('.category-icon i').style.color = '';
    
    // Add archive icon to label if not present  
    const label = categoryCard.querySelector('.category-label');
    if (!label.querySelector('.material-icons')) {
      label.innerHTML += '<i class="material-icons text-amber-600 text-sm ml-1.5 align-middle">archive</i>';
    }
  } else {
    categoryCard.classList.remove('border-gray-300', 'opacity-60', 'archived-category');
    const contentTypeColor = getComputedStyle(document.documentElement).getPropertyValue('--content-type-color') || '#6366f1';
    categoryCard.style.borderColor = contentTypeColor;
    categoryCard.querySelector('.category-header').style.backgroundColor = contentTypeColor + '20';
    categoryCard.querySelector('.category-icon i').classList.remove('text-gray-400');
    categoryCard.querySelector('.category-icon i').style.color = contentTypeColor;
    
    // Remove archive icon from label
    const archiveIcon = categoryCard.querySelector('.category-label .material-icons');
    if (archiveIcon) {
      archiveIcon.remove();
    }
  }
  
  // Update archived status in category details
  const statusText = categoryCard.querySelector('.category-label').parentElement.querySelector('p');
  if (statusText) {
    // Remove existing status spans
    statusText.querySelectorAll('span').forEach(span => {
      if (span.textContent.includes('Hidden') || span.textContent.includes('Archived')) {
        span.remove();
      }
    });
    
    // Add archived status if needed
    if (isArchived) {
      const archivedSpan = document.createElement('span');
      archivedSpan.className = 'text-amber-600 ml-2';
      archivedSpan.textContent = '— Archived';
      statusText.appendChild(archivedSpan);
    }
  }
  
  // Hide archived category if show archived is off
  const showArchivedToggle = document.querySelector('input[x-model="showArchived"]');
  if (showArchivedToggle && !showArchivedToggle.checked && isArchived) {
    categoryCard.style.display = 'none';
  } else if (!isArchived) {
    categoryCard.style.display = '';
  }
}

// Update archived items count in the settings panel
function updateArchivedItemsCount() {
  const archivedFields = document.querySelectorAll('.field-item[data-archived="true"]');
  const archivedCategories = document.querySelectorAll('.category-card[data-archived="true"]');
  const totalArchived = archivedFields.length + archivedCategories.length;
  
  // Update Alpine.js data for count display
  const alpineElement = document.querySelector('[x-data*="showArchived"]');
  if (alpineElement && alpineElement._x_dataStack) {
    const alpine = alpineElement._x_dataStack[0];
    if (alpine && typeof alpine.archivedItemsCount !== 'undefined') {
      alpine.archivedItemsCount = totalArchived;
    }
  }
}

// Make functions globally available
window.updateArchivedItemsCount = updateArchivedItemsCount;
// Legacy function name for backwards compatibility
window.updateArchivedFieldsCount = updateArchivedItemsCount;

// Select All / Select None functions for link field configuration
window.selectAllLinkableTypes = function() {
  const checkboxes = document.querySelectorAll('input[name="attribute_field[field_options][linkable_types][]"]:not([value=""])');
  checkboxes.forEach(checkbox => {
    checkbox.checked = true;
  });
};

window.selectNoneLinkableTypes = function() {
  const checkboxes = document.querySelectorAll('input[name="attribute_field[field_options][linkable_types][]"]:not([value=""])');
  checkboxes.forEach(checkbox => {
    checkbox.checked = false;
  });
};

// Show first-time archive tip
function showArchiveTip() {
  const tip = document.createElement('div');
  tip.className = 'archive-tip-popup fixed bottom-4 right-4 bg-blue-600 text-white p-4 rounded-lg shadow-lg max-w-sm z-50';
  tip.innerHTML = `
    <div class="flex items-start">
      <i class="material-icons text-white mr-2">lightbulb_outline</i>
      <div class="flex-1">
        <div class="font-medium">Archive System</div>
        <div class="text-sm mt-1">
          Archived categories and fields are greyed out to show where they would restore to while keeping them out of your active workspace.
        </div>
        <button onclick="this.parentElement.parentElement.parentElement.remove()" 
                class="text-xs underline mt-2 hover:text-blue-200">
          Got it!
        </button>
      </div>
    </div>
  `;
  
  document.body.appendChild(tip);
  
  // Auto-remove tip after 8 seconds
  setTimeout(() => {
    if (tip.parentElement) {
      tip.remove();
    }
  }, 8000);
}

// Initialize archived items count on page load
document.addEventListener('DOMContentLoaded', function() {
  updateArchivedItemsCount();
});

// Detect screen size changes to adjust UI
window.addEventListener('resize', function() {
  const alpine = Alpine.getRoot(document.querySelector('.attributes-editor'));
  if (alpine && alpine.$data) {
    if (window.innerWidth >= 768) {
      alpine.$data.activePanel = 'both';
    } else if (alpine.$data.configuring) {
      alpine.$data.activePanel = 'config';
    } else {
      alpine.$data.activePanel = 'template';
    }
  }
});