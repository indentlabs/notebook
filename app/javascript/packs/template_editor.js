// Template Editor JavaScript

document.addEventListener('DOMContentLoaded', function() {
  // Initialize Alpine component data
  window.initTemplateEditor = function() {
    return {
      selectedCategory: null,
      selectedField: null,
      configuring: false,
      activePanel: window.innerWidth >= 768 ? 'both' : 'template',
      
      // Category selection
      selectCategory(categoryId) {
        this.selectedCategory = categoryId;
        this.selectedField = null;
        this.configuring = true;
        
        if (window.innerWidth < 768) {
          this.activePanel = 'config';
        }
        
        // Load category configuration via AJAX
        fetch(`/plan/attribute_categories/${categoryId}/edit`)
          .then(response => response.text())
          .then(html => {
            document.getElementById('category-config-container').innerHTML = html;
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
        
        // Load field configuration via AJAX
        fetch(`/plan/attribute_fields/${fieldId}/edit`)
          .then(response => response.text())
          .then(html => {
            document.getElementById('field-config-container').innerHTML = html;
          });
      }
    };
  };
  
  // Initialize sortable for categories
  initSortables();
  
  // Show category form
  document.addEventListener('click', function(event) {
    if (event.target.closest('[data-action="click->attributes-editor#showAddCategoryForm"]')) {
      const form = document.getElementById('add-category-form');
      form.classList.toggle('hidden');
    }
  });
  
  // Handle select-category event dispatched from category cards
  document.addEventListener('select-category', function(event) {
    const alpine = Alpine.getRoot(document.querySelector('.attributes-editor'));
    alpine.$data.selectCategory(event.detail.id);
  });
  
  // Handle select-field event dispatched from field items
  document.addEventListener('select-field', function(event) {
    const alpine = Alpine.getRoot(document.querySelector('.attributes-editor'));
    alpine.$data.selectField(event.detail.id);
  });
  
  // Category suggestions
  document.querySelectorAll('.js-show-category-suggestions').forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const contentType = document.querySelector('.attributes-editor').dataset.contentType;
      const resultContainer = this.closest('div').querySelector('.suggest-categories-container');
      
      fetch(`/api/v1/categories/suggest/${contentType}`)
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
      
      fetch(`/api/v1/fields/suggest/${contentType}/${categoryLabel}`)
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
      
      // AJAX request to update position
      $.ajax({
        url: '/api/v1/content/sort',
        type: 'PUT',
        contentType: 'application/json',
        data: JSON.stringify({
          sortable_class: 'AttributeCategory',
          content_id: categoryId,
          intended_position: newPosition
        }),
        success: function(data) {
          console.log('Category position updated successfully');
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
      
      // AJAX request to update position
      $.ajax({
        url: '/api/v1/content/sort',
        type: 'PUT',
        contentType: 'application/json',
        data: JSON.stringify({
          sortable_class: 'AttributeField',
          content_id: fieldId,
          intended_position: newPosition,
          attribute_category_id: categoryId
        }),
        success: function(data) {
          console.log('Field position updated successfully');
        },
        error: function(xhr, status, error) {
          console.error('Error updating field position:', error);
          showErrorMessage('Failed to reorder fields. Please try again.');
        }
      });
    }
  });
}

// Function to show error messages to users
function showErrorMessage(message) {
  // Use Materialize toast if available, otherwise create custom notification
  if (typeof M !== 'undefined' && M.toast) {
    M.toast({html: message, classes: 'red'});
  } else {
    const notification = document.createElement('div');
    notification.className = 'fixed top-4 right-4 bg-red-500 text-white px-4 py-2 rounded-md shadow-lg z-50';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 5000);
  }
}

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