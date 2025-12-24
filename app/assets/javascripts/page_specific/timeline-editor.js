// Initialize timeline events sortable functionality
function initTimelineEventsSortable() {
  // Check if jQuery UI is available
  if (typeof $ === 'undefined' || !$.fn.sortable) {
    console.error('jQuery UI Sortable not found - drag and drop disabled');
    return;
  }

  const eventsContainer = $('.timeline-events-container');
  if (!eventsContainer.length) return;

  eventsContainer.sortable({
    items: '.timeline-event-container:not(.timeline-event-template)',
    handle: '.timeline-event-drag-handle',
    placeholder: 'timeline-event-placeholder',
    cursor: 'grabbing',
    opacity: 0.8,
    tolerance: 'pointer',
    distance: 10, // Prevent accidental drags
    helper: 'clone',
    start: function(event, ui) {
      // Add visual feedback
      ui.item.addClass('timeline-event-dragging');
      ui.placeholder.addClass('timeline-event-placeholder');

      // Store original position for rollback if needed (count only event containers)
      const allEvents = $('.timeline-events-container .timeline-event-container:not(.timeline-event-template)');
      ui.item.data('original-position', allEvents.index(ui.item));
    },
    update: function(event, ui) {
      const eventId = ui.item.attr('data-event-id');
      const originalPosition = ui.item.data('original-position');

      // Count only the event containers before this one (not timeline header/rail)
      const allEvents = $('.timeline-events-container .timeline-event-container:not(.timeline-event-template)');
      const newPosition = allEvents.index(ui.item);

      if (!eventId) {
        console.error('Event ID not found');
        return;
      }

      // Send the position directly - backend will convert to 1-based indexing
      const targetPosition = newPosition;

      // Show loading state
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl) {
        Alpine.$data(alpineEl).autoSaveStatus = 'saving';
      }

      // AJAX request to update position using new internal endpoint
      $.ajax({
        url: '/internal/sort/timeline_events',
        type: 'PATCH',
        contentType: 'application/json',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        data: JSON.stringify({
          content_id: eventId,
          intended_position: targetPosition
        }),
        success: function(data) {
          console.log('Timeline event position updated successfully:', data);

          // Update Alpine.js save status
          if (alpineEl) {
            Alpine.$data(alpineEl).autoSaveStatus = 'saved';
            setTimeout(() => {
              if (Alpine.$data(alpineEl).autoSaveStatus === 'saved') {
                Alpine.$data(alpineEl).autoSaveStatus = 'saved';
              }
            }, 2000);
          }

          if (data.message) {
            showTimelineSuccessMessage(data.message);
          }
        },
        error: function(xhr, status, error) {
          console.error('Error updating timeline event position:', error);

          // Update Alpine.js save status
          if (alpineEl) {
            Alpine.$data(alpineEl).autoSaveStatus = 'error';
          }

          // Revert to original position
          const originalPosition = ui.item.data('original-position');
          if (typeof originalPosition !== 'undefined') {
            revertEventPosition(ui.item, originalPosition);
          }

          showTimelineErrorMessage('Failed to reorder events. Please try again.');
        }
      });
    },
    stop: function(event, ui) {
      // Remove visual feedback
      ui.item.removeClass('timeline-event-dragging');
    }
  });

  // Add custom CSS for drag feedback and content drag & drop
  if (!document.getElementById('timeline-drag-styles')) {
    const style = document.createElement('style');
    style.id = 'timeline-drag-styles';
    style.textContent = `
      .timeline-event-placeholder {
        height: 120px !important;
        background: linear-gradient(45deg, #f3f4f6 25%, transparent 25%),
                    linear-gradient(-45deg, #f3f4f6 25%, transparent 25%),
                    linear-gradient(45deg, transparent 75%, #f3f4f6 75%),
                    linear-gradient(-45deg, transparent 75%, #f3f4f6 75%);
        background-size: 20px 20px;
        background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
        border: 2px dashed #10b981;
        border-radius: 0.75rem;
        margin: 0 0 2rem 0;
        opacity: 0.7;
        position: relative;
      }

      .timeline-event-placeholder:before {
        content: 'Drop event here';
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        color: #10b981;
        font-weight: 500;
        font-size: 0.875rem;
      }

      .timeline-event-dragging {
        transform: rotate(2deg);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        z-index: 1000;
      }

      .ui-sortable-helper {
        width: auto !important;
        max-width: 600px;
      }

      /* Content drag & drop styles */
      .draggable-content-item {
        user-select: none;
      }

      .draggable-content-item.dragging {
        opacity: 0.5;
        transform: scale(0.95);
      }

      .event-drop-zone.drop-zone-active {
        border-color: #10b981 !important;
        border-width: 2px !important;
        background-color: #f0fdf4 !important;
      }

      .event-drop-zone.drop-zone-hover {
        border-color: #059669 !important;
        box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1) !important;
        transform: scale(1.02);
      }

      .drop-indicator {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        pointer-events: none;
        z-index: 10;
        background: rgba(16, 185, 129, 0.9);
        color: white;
        padding: 8px 16px;
        border-radius: 6px;
        font-size: 0.875rem;
        font-weight: 500;
      }
    `;
    document.head.appendChild(style);
  }

  // Initialize content drag & drop functionality
  initContentDragDrop();
}

// Initialize drag & drop for content linking
function initContentDragDrop() {
  // Set up drag handlers for content items
  document.addEventListener('dragstart', function(e) {
    if (e.target.classList.contains('draggable-content-item')) {
      const contentType = e.target.dataset.contentType;
      const contentId = e.target.dataset.contentId;
      const contentName = e.target.dataset.contentName;

      // Store data for drop handler
      e.dataTransfer.setData('application/json', JSON.stringify({
        contentType: contentType,
        contentId: contentId,
        contentName: contentName
      }));

      e.dataTransfer.effectAllowed = 'copy';

      // Add dragging visual state
      e.target.classList.add('dragging');

      // Show all event drop zones
      document.querySelectorAll('.event-drop-zone').forEach(zone => {
        zone.classList.add('drop-zone-active');
      });
    }
  });

  document.addEventListener('dragend', function(e) {
    if (e.target.classList.contains('draggable-content-item')) {
      // Remove dragging visual state
      e.target.classList.remove('dragging');

      // Hide all event drop zones
      document.querySelectorAll('.event-drop-zone').forEach(zone => {
        zone.classList.remove('drop-zone-active', 'drop-zone-hover');
        // Remove any drop indicators
        const indicator = zone.querySelector('.drop-indicator');
        if (indicator) indicator.remove();
      });
    }
  });

  // Set up drop handlers for timeline events
  document.addEventListener('dragover', function(e) {
    if (e.target.closest('.event-drop-zone')) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'copy';

      const dropZone = e.target.closest('.event-drop-zone');
      dropZone.classList.add('drop-zone-hover');

      // Add drop indicator if not already present
      if (!dropZone.querySelector('.drop-indicator')) {
        const indicator = document.createElement('div');
        indicator.className = 'drop-indicator';
        indicator.textContent = 'Drop to link content';
        dropZone.style.position = 'relative';
        dropZone.appendChild(indicator);
      }
    }
  });

  document.addEventListener('dragleave', function(e) {
    const dropZone = e.target.closest('.event-drop-zone');
    if (dropZone && !dropZone.contains(e.relatedTarget)) {
      dropZone.classList.remove('drop-zone-hover');
      const indicator = dropZone.querySelector('.drop-indicator');
      if (indicator) indicator.remove();
    }
  });

  document.addEventListener('drop', function(e) {
    const dropZone = e.target.closest('.event-drop-zone');
    if (dropZone) {
      e.preventDefault();

      try {
        const dragData = JSON.parse(e.dataTransfer.getData('application/json'));
        const eventId = dropZone.dataset.eventId;

        if (eventId && dragData.contentType && dragData.contentId) {
          linkContentToEvent(eventId, dragData.contentType, dragData.contentId, dragData.contentName, dropZone);
        }
      } catch (error) {
        console.error('Error parsing drag data:', error);
      }

      // Clean up visual states
      dropZone.classList.remove('drop-zone-hover', 'drop-zone-active');
      const indicator = dropZone.querySelector('.drop-indicator');
      if (indicator) indicator.remove();
    }
  });
}

// Replace linked content section with server-rendered HTML
function replaceLinkedContentSection(eventId, html) {
  const eventContainer = document.querySelector(`[data-event-id="${eventId}"]`);
  if (!eventContainer) return;

  // Find the current linked content section or the location where it should be inserted
  const existingSection = eventContainer.querySelector(`#linked-content-${eventId}`);
  const cardBody = eventContainer.querySelector('.px-6.py-4.space-y-4');

  if (existingSection) {
    // Replace existing section
    existingSection.outerHTML = html;
  } else if (cardBody && html.trim()) {
    // Insert new section at the end of the card body
    cardBody.insertAdjacentHTML('beforeend', html);
  }

  // Add entrance animation to the new section
  const newSection = eventContainer.querySelector(`#linked-content-${eventId}`);
  if (newSection) {
    newSection.style.opacity = '0';
    newSection.style.transform = 'translateY(-10px)';
    setTimeout(() => {
      newSection.style.transition = 'all 0.3s ease-out';
      newSection.style.opacity = '1';
      newSection.style.transform = 'translateY(0)';
    }, 10);
  }
}

// Link content to timeline event via drag & drop
function linkContentToEvent(eventId, contentType, contentId, contentName, dropZone) {
  // Show loading indicator
  const loadingIndicator = document.createElement('div');
  loadingIndicator.className = 'drop-indicator';
  loadingIndicator.innerHTML = '<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2 inline-block"></div>Linking...';
  dropZone.style.position = 'relative';
  dropZone.appendChild(loadingIndicator);

  // Set Alpine.js auto-save status to saving
  const alpineEl = document.querySelector('[x-data]');
  if (alpineEl) {
    Alpine.$data(alpineEl).autoSaveStatus = 'saving';
  }

  fetch(`/plan/timeline_events/${eventId}/link`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content')
    },
    body: JSON.stringify({
      entity_type: contentType,
      entity_id: contentId
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.status === 'success') {
      // Replace the linked content section with server-rendered HTML
      replaceLinkedContentSection(eventId, data.html);

      // Update sidebar linked content if this event is selected
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl && Alpine.$data(alpineEl).selectedEventId == eventId) {
        Alpine.$data(alpineEl).updateSidebarLinkedContent(eventId);
      }

      // Show success feedback
      loadingIndicator.innerHTML = '<i class="material-icons text-sm mr-1">check_circle</i>Linked!';
      loadingIndicator.className = 'drop-indicator';

      // Update Alpine.js save status
      if (alpineEl) {
        Alpine.$data(alpineEl).autoSaveStatus = 'saved';
      }

      setTimeout(() => {
        loadingIndicator.remove();
      }, 2000);

      showTimelineSuccessMessage(`${contentName} linked to event successfully!`);
    } else {
      throw new Error(data.message || 'Failed to link content');
    }
  })
  .catch(error => {
    console.error('Error linking content:', error);

    // Show error feedback
    loadingIndicator.innerHTML = '<i class="material-icons text-sm mr-1">error</i>Failed';
    loadingIndicator.className = 'drop-indicator';
    loadingIndicator.style.background = 'rgba(239, 68, 68, 0.9)';

    // Update Alpine.js save status
    const alpineEl = document.querySelector('[x-data]');
    if (alpineEl) {
      Alpine.$data(alpineEl).autoSaveStatus = 'error';
    }

    setTimeout(() => {
      loadingIndicator.remove();
    }, 3000);

    showTimelineErrorMessage('Failed to link content. Please try again.');
  });
}

// Helper function to revert event position on error
function revertEventPosition(eventItem, originalPosition) {
  const eventsContainer = eventItem.parent();
  const allEvents = eventsContainer.children('.timeline-event-container:not(.timeline-event-template)');

  if (originalPosition === 0) {
    // Insert before the first event (after header/rail)
    allEvents.first().before(eventItem);
  } else if (originalPosition >= allEvents.length - 1) {
    // Insert after the last event
    allEvents.last().after(eventItem);
  } else {
    // Insert before the event at the target position
    allEvents.eq(originalPosition).before(eventItem);
  }
}

// Timeline-specific notification functions
function showTimelineSuccessMessage(message) {
  showNotificationToast(message, 'success');
}

function showTimelineErrorMessage(message) {
  showNotificationToast(message, 'error');
}

function showNotificationToast(message, type = 'info') {
  const bgColor = type === 'success' ? 'bg-green-500' : type === 'error' ? 'bg-red-500' : 'bg-blue-500';
  const icon = type === 'success' ? 'check_circle' : type === 'error' ? 'error' : 'info';

  const toast = $(`
    <div class="fixed top-4 right-4 ${bgColor} text-white px-6 py-3 rounded-lg shadow-lg z-50 flex items-center transform translate-x-full transition-transform">
      <i class="material-icons text-sm mr-2">${icon}</i>
      <span class="text-sm font-medium">${message}</span>
      <button class="ml-4 text-white hover:text-gray-200" onclick="$(this).parent().remove()">
        <i class="material-icons text-sm">close</i>
      </button>
    </div>
  `);

  $('body').append(toast);

  // Animate in
  setTimeout(() => {
    toast.removeClass('translate-x-full');
  }, 10);

  // Auto-remove after 4 seconds
  setTimeout(() => {
    toast.addClass('translate-x-full');
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

document.addEventListener('DOMContentLoaded', function() {

  // Initialize timeline events drag and drop
  initTimelineEventsSortable();

  // Auto-save functionality
  document.addEventListener('ajax:success', function(event) {

    if (event.target.matches('.timeline-meta-form, .autosave-form')) {
      // Update autoSaveStatus through Alpine data
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl) {
        Alpine.$data(alpineEl).autoSaveStatus = 'saved';
        setTimeout(() => {
          Alpine.$data(alpineEl).autoSaveStatus = 'saved';
        }, 2000);
      }
    }
  });

  document.addEventListener('ajax:error', function(event) {

    if (event.target.matches('.timeline-meta-form, .autosave-form')) {
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl) {
        Alpine.$data(alpineEl).autoSaveStatus = 'error';
      }
    }
  });

  // Create timeline event
  document.getElementById('js-create-timeline-event').addEventListener('click', function() {
    const timelineId = document.querySelector('.timeline-events-container').dataset.timelineId;
    createTimelineEvent(timelineId);
  });

  // Create first timeline event
  const firstEventBtn = document.getElementById('js-create-first-event');
  if (firstEventBtn) {
    firstEventBtn.addEventListener('click', function() {
      const timelineId = document.querySelector('.timeline-events-container').dataset.timelineId;
      createTimelineEvent(timelineId);
    });
  }

  function createTimelineEvent(timelineId) {

    // Show loading state
    const createBtn = document.getElementById('js-create-timeline-event');
    const originalText = createBtn.innerHTML;
    createBtn.disabled = true;
    createBtn.innerHTML = '<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2 inline-block"></div>Creating...';

    const alpineEl = document.querySelector('[x-data]');
    if (alpineEl) Alpine.$data(alpineEl).autoSaveStatus = 'saving';

    fetch('/plan/timeline_events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content')
      },
      body: JSON.stringify({
        timeline_event: {
          title: "Untitled Event",
          timeline_id: timelineId,
          event_type: "general",
          status: "completed"
        }
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success' && data.html) {
        addEventToTimeline(data.id, data.html);
        const alpineEl = document.querySelector('[x-data]');
        if (alpineEl) Alpine.$data(alpineEl).autoSaveStatus = 'saved';
      } else {
        throw new Error('Failed to create event');
      }
    })
    .catch(error => {
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl) Alpine.$data(alpineEl).autoSaveStatus = 'error';
      showErrorMessage('Failed to create timeline event. Please try again.');
    })
    .finally(() => {
      // Reset button state
      createBtn.disabled = false;
      createBtn.innerHTML = originalText;
    });
  }

  function addEventToTimeline(eventId, html) {
    const eventsContainer = document.querySelector('.timeline-events-container');

    // Hide empty state if it exists
    const emptyState = eventsContainer.querySelector('.text-center.py-16');
    if (emptyState) {
      emptyState.style.display = 'none';
    }

    // Insert the server-rendered HTML
    eventsContainer.insertAdjacentHTML('beforeend', html);

    // Get reference to the newly added event
    const newEvent = eventsContainer.querySelector(`[data-event-id="${eventId}"]`);
    if (!newEvent) {
      showErrorMessage('Failed to add event to timeline. Please refresh the page.');
      return;
    }

    // Add entrance animation
    newEvent.style.opacity = '0';
    newEvent.style.transform = 'translateY(-20px)';

    // Trigger animation
    setTimeout(() => {
      newEvent.style.transition = 'all 0.3s ease-out';
      newEvent.style.opacity = '1';
      newEvent.style.transform = 'translateY(0)';
    }, 10);

    // Update event count in header
    const eventCount = eventsContainer.querySelectorAll('.timeline-event-container:not(.timeline-event-template)').length;
    updateEventCount(eventCount);

    // Initialize drag and drop for the new event (if sortable is initialized)
    if ($.fn.sortable && $(eventsContainer).hasClass('ui-sortable')) {
      $(eventsContainer).sortable('refresh');
    }

    // Auto-select the newly created event in the Event Details panel
    const alpineEl = document.querySelector('[x-data]');
    if (alpineEl) {
      setTimeout(() => {
        const alpineData = Alpine.$data(alpineEl);
        if (alpineData && typeof alpineData.selectEvent === 'function') {
          // Extract event data from the newly added element
          const title = newEvent.querySelector('input[name*="[title]"]');
          const timeLabel = newEvent.querySelector('input[name*="[time_label]"]');
          const endTimeLabel = newEvent.querySelector('input[name*="[end_time_label]"]');
          const description = newEvent.querySelector('textarea[name*="[description]"]');

          const eventData = {
            id: eventId,
            title: title ? title.value : 'Untitled Event',
            time_label: timeLabel ? timeLabel.value : '',
            end_time_label: endTimeLabel ? endTimeLabel.value : '',
            description: description ? description.value : '',
            event_type: newEvent.dataset.eventType || 'general',
            status: newEvent.dataset.status || 'completed',
            tags: []
          };

          alpineData.selectEvent(eventId, eventData);
        }
      }, 100);
    }

    // Focus on the title field for immediate editing
    setTimeout(() => {
      const titleField = newEvent.querySelector('input[name*="[title]"]');
      if (titleField) {
        titleField.focus();
        titleField.select();
      }
    }, 350);

    // Scroll the new event into view
    setTimeout(() => {
      newEvent.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);
  }

  function updateEventCount(count) {
    const eventCountElement = document.querySelector('.hidden.sm\\:flex .text-sm.text-gray-600');
    if (eventCountElement) {
      const text = count === 1 ? '1 event' : `${count} events`;
      eventCountElement.firstChild.textContent = text;
    }
  }

  function showErrorMessage(message) {
    // Create and show a toast notification
    const toast = document.createElement('div');
    toast.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 transform translate-x-full transition-transform';
    toast.innerHTML = `
      <div class="flex items-center">
        <i class="material-icons mr-2">error</i>
        <span>${message}</span>
        <button onclick="this.parentElement.parentElement.remove()" class="ml-4 hover:text-red-200">
          <i class="material-icons">close</i>
        </button>
      </div>
    `;

    document.body.appendChild(toast);

    // Animate in
    setTimeout(() => {
      toast.style.transform = 'translateX(0)';
    }, 10);

    // Auto remove after 5 seconds
    setTimeout(() => {
      if (toast.parentElement) {
        toast.style.transform = 'translateX(full)';
        setTimeout(() => toast.remove(), 300);
      }
    }, 5000);
  }

  // Link entity functionality
  document.addEventListener('click', function(event) {
    if (event.target.matches('.js-link-entity-selection') || event.target.closest('.js-link-entity-selection')) {
      const button = event.target.matches('.js-link-entity-selection') ? event.target : event.target.closest('.js-link-entity-selection');
      const entityType = button.dataset.type;
      const entityId = button.dataset.id;
      const alpineEl = document.querySelector('[x-data*="timelineEditor"]');
      const eventId = alpineEl && alpineEl._x_dataStack ? alpineEl._x_dataStack[0].linkingEventId : null;

      if (eventId) {
        // Show loading state on the clicked button
        const originalContent = button.innerHTML;
        button.innerHTML = '<div class="flex items-center"><div class="animate-spin rounded-full h-4 w-4 border-b-2 border-green-500 mr-2"></div>Linking...</div>';
        button.disabled = true;

        fetch(`/plan/timeline_events/${eventId}/link`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content')
          },
          body: JSON.stringify({
            entity_type: entityType,
            entity_id: entityId
          })
        })
        .then(response => response.json())
        .then(data => {
          if (data.status === 'success') {
            // Replace the linked content section with server-rendered HTML
            replaceLinkedContentSection(eventId, data.html);

            // Update sidebar linked content if this event is selected
            const alpineEl = document.querySelector('[x-data]');
            if (alpineEl && Alpine.$data(alpineEl).selectedEventId == eventId) {
              Alpine.$data(alpineEl).updateSidebarLinkedContent(eventId);
            }

            // Show success feedback on the button itself
            const originalContent = button.innerHTML;
            button.innerHTML = '<div class="flex items-center justify-between text-green-600"><div class="flex items-center"><i class="material-icons text-sm mr-2">check_circle</i><span>Added!</span></div></div>';
            button.classList.add('bg-green-50', 'border-green-300', 'text-green-800');

            // Reset button after 2 seconds but show linked state with name
            setTimeout(() => {
              const entityName = button.dataset.name || 'Content';
              button.innerHTML = `<div class="flex items-center justify-between text-gray-500"><div class="flex items-center min-w-0"><i class="material-icons text-sm mr-2">check_circle</i><span class="truncate">${entityName}</span></div><span class="text-xs ml-2 flex-shrink-0">Linked</span></div>`;
              button.classList.remove('bg-green-50', 'border-green-300', 'text-green-800');
              button.classList.add('bg-gray-50', 'border-gray-300', 'text-gray-500', 'cursor-not-allowed');
              button.disabled = true;
            }, 2000);
          } else {
            throw new Error(data.message || 'Failed to link content');
          }
        })
        .catch(error => {
            showErrorMessage('Error linking content. Please try again.');
        })
        .finally(() => {
          // Reset button state
          button.innerHTML = originalContent;
          button.disabled = false;
        });
      }
    }
  });


  // Update unlink functionality to use Rails UJS instead of manual fetch
  // The unlink buttons now have remote: true, so they'll be handled by Rails UJS
  document.addEventListener('ajax:success', function(event) {
    if (event.target.matches('a[href*="/unlink/"]')) {
      const response = event.detail[0];
      if (response.status === 'success') {
        // Extract event ID from the URL
        const eventId = event.target.href.match(/\/timeline_events\/(\d+)\/unlink/)[1];
        replaceLinkedContentSection(eventId, response.html);

        // Update sidebar linked content if this event is selected
        const alpineEl = document.querySelector('[x-data]');
        if (alpineEl && Alpine.$data(alpineEl).selectedEventId == eventId) {
          Alpine.$data(alpineEl).updateSidebarLinkedContent(eventId);
        }

        showSuccessMessage(response.message || 'Content unlinked successfully!');
      }
    }
  });

  function showSuccessMessage(message) {
    const toast = document.createElement('div');
    toast.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 transform translate-x-full transition-transform';
    toast.innerHTML = `
      <div class="flex items-center">
        <i class="material-icons mr-2">check_circle</i>
        <span>${message}</span>
        <button onclick="this.parentElement.parentElement.remove()" class="ml-4 hover:text-green-200">
          <i class="material-icons">close</i>
        </button>
      </div>
    `;

    document.body.appendChild(toast);

    // Animate in
    setTimeout(() => {
      toast.style.transform = 'translateX(0)';
    }, 10);

    // Auto remove after 3 seconds
    setTimeout(() => {
      if (toast.parentElement) {
        toast.style.transform = 'translateX(full)';
        setTimeout(() => toast.remove(), 300);
      }
    }, 3000);
  }

  // Move event handlers
  document.addEventListener('click', function(event) {
    const eventContainer = event.target.closest('.timeline-event-container');
    const eventId = eventContainer?.dataset.eventId;

    if (!eventId || eventId === '-1') return;

    let endpoint = null;
    if (event.target.closest('.js-move-event-to-top')) {
      endpoint = `/plan/timeline_events/${eventId}/move/top`;
    } else if (event.target.closest('.js-move-event-up')) {
      endpoint = `/plan/timeline_events/${eventId}/move/up`;
    } else if (event.target.closest('.js-move-event-down')) {
      endpoint = `/plan/timeline_events/${eventId}/move/down`;
    } else if (event.target.closest('.js-move-event-to-bottom')) {
      endpoint = `/plan/timeline_events/${eventId}/move/bottom`;
    }

    if (endpoint) {
      event.preventDefault();
      fetch(endpoint, {
        method: 'GET',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content')
        }
      })
      .then(() => {
        moveEventInDOM(eventContainer, endpoint);
        showSuccessMessage('Event moved successfully!');
      })
      .catch(error => {
        showErrorMessage('Error moving event. Please try again.');
      });
    }
  });

  function moveEventInDOM(eventContainer, endpoint) {
    const eventsContainer = eventContainer.parentElement;
    const allEvents = Array.from(eventsContainer.children).filter(el =>
      el.classList.contains('timeline-event-container') &&
      !el.classList.contains('timeline-event-template')
    );

    const currentIndex = allEvents.indexOf(eventContainer);
    let newIndex;

    // Determine new position based on action
    if (endpoint.includes('/top')) {
      newIndex = 0;
    } else if (endpoint.includes('/bottom')) {
      newIndex = allEvents.length - 1;
    } else if (endpoint.includes('/up')) {
      newIndex = Math.max(0, currentIndex - 1);
    } else if (endpoint.includes('/down')) {
      newIndex = Math.min(allEvents.length - 1, currentIndex + 1);
    }

    // Only move if position actually changes
    if (newIndex !== currentIndex) {
      // Add animation class
      eventContainer.style.transition = 'all 0.3s ease-out';
      eventContainer.style.transform = 'scale(1.02)';
      eventContainer.style.boxShadow = '0 10px 25px rgba(0,0,0,0.1)';

      setTimeout(() => {
        // Move in DOM
        if (newIndex === 0) {
          eventsContainer.insertBefore(eventContainer, allEvents[0]);
        } else if (newIndex === allEvents.length - 1) {
          eventsContainer.appendChild(eventContainer);
        } else {
          const referenceEvent = allEvents[newIndex];
          if (currentIndex < newIndex) {
            eventsContainer.insertBefore(eventContainer, referenceEvent.nextSibling);
          } else {
            eventsContainer.insertBefore(eventContainer, referenceEvent);
          }
        }

        // Reset animation
        setTimeout(() => {
          eventContainer.style.transform = 'scale(1)';
          eventContainer.style.boxShadow = '';

          setTimeout(() => {
            eventContainer.style.transition = '';
          }, 300);
        }, 50);

        // Scroll into view
        eventContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }, 150);
    }
  }

  // Global function for unlinking from sidebar
  window.unlinkFromSidebar = function(unlinkHref, button) {

    // Show loading state
    const originalHTML = button.innerHTML;
    button.innerHTML = '<div class="animate-spin rounded-full h-3 w-3 border-b-2 border-red-500"></div>';
    button.disabled = true;

    // Make request to unlink
    fetch(unlinkHref, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        // Update main linked content section
        const eventId = unlinkHref.match(/timeline_events\/(\d+)\/unlink/)[1];
        replaceLinkedContentSection(eventId, data.html);

        // Update sidebar
        const alpineEl = document.querySelector('[x-data]');
        if (alpineEl && Alpine.$data(alpineEl).selectedEventId) {
          Alpine.$data(alpineEl).updateSidebarLinkedContent(Alpine.$data(alpineEl).selectedEventId);
        }

        showSuccessMessage(data.message || 'Content unlinked successfully!');
      } else {
        throw new Error(data.message || 'Failed to unlink content');
      }
    })
    .catch(error => {
      button.innerHTML = originalHTML;
      button.disabled = false;
      showErrorMessage('Error unlinking content. Please try again.');
    });
  };

  // Make deleteEvent globally available
  window.deleteEvent = function(eventId, button) {
    const eventContainer = button.closest('.timeline-event-container');

    // If this is a template event (not yet saved), just remove it
    if (!eventId || eventId === 'null') {
      eventContainer.remove();
      return;
    }

    // Show confirmation modal
    if (!confirm('Are you sure you want to delete this event? This cannot be undone.')) {
      return;
    }

    // Show loading state
    const originalIcon = button.innerHTML;
    button.innerHTML = '<div class="animate-spin rounded-full h-4 w-4 border-b-2 border-red-500"></div>';
    button.disabled = true;

    fetch(`/plan/timeline_events/${eventId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content')
      }
    })
    .then(() => {
      // Clear inspector selection if this event was selected
      const alpineEl = document.querySelector('[x-data]');
      if (alpineEl && Alpine.$data(alpineEl).selectedEventId == eventId) {
        Alpine.$data(alpineEl).clearEventSelection();
      }

      // Animate removal
      eventContainer.style.transition = 'all 0.3s ease-in';
      eventContainer.style.opacity = '0';
      eventContainer.style.transform = 'translateX(-20px)';

      setTimeout(() => {
        eventContainer.remove();

        // Update event count
        const eventsContainer = document.querySelector('.timeline-events-container');
        const eventCount = eventsContainer.querySelectorAll('.timeline-event-container:not(.timeline-event-template)').length;
        updateEventCount(eventCount);

        // Show empty state if no events remain
        if (eventCount === 0) {
          showEmptyState();
        }

        showSuccessMessage('Event deleted successfully!');
      }, 300);
    })
    .catch(error => {
      button.innerHTML = originalIcon;
      button.disabled = false;
      showErrorMessage('Error deleting event. Please try again.');
    });
  };

  function showEmptyState() {
    const eventsContainer = document.querySelector('.timeline-events-container');
    const emptyState = document.createElement('div');
    emptyState.className = 'text-center py-16';
    emptyState.innerHTML = `
      <div class="mx-auto h-24 w-24 rounded-full bg-gradient-to-br from-green-100 to-green-200 flex items-center justify-center mb-6 shadow-sm">
        <i class="material-icons text-4xl text-green-600">timeline</i>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-3">Your timeline is empty</h3>
      <p class="text-gray-600 mb-8 max-w-md mx-auto">
        Start building your timeline by adding your first event. Track important moments, plot points, and key developments in chronological order.
      </p>
      <button id="js-create-first-event"
              class="inline-flex items-center px-6 py-3 text-base font-medium rounded-lg text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 shadow-sm">
        <i class="material-icons text-lg mr-2">add</i>
        Add Your First Event
      </button>
    `;

    // Add event listener to the new button
    const newFirstEventBtn = emptyState.querySelector('#js-create-first-event');
    newFirstEventBtn.addEventListener('click', function() {
      const timelineId = document.querySelector('.timeline-events-container').dataset.timelineId;
      createTimelineEvent(timelineId);
      emptyState.remove(); // Remove empty state when creating
    });

    eventsContainer.appendChild(emptyState);
  }
});
