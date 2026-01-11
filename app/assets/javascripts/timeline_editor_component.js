// Timeline Editor Alpine.js Component
// Extracted from timelines/edit.html.erb for maintainability
//
// Usage: Add a JSON data block in the view:
// <script type="application/json" id="timeline-editor-init-data">
//   <%= { timeline: {...}, tags: [...], ... }.to_json.html_safe %>
// </script>

// Event types configuration - loaded from server via JSON block
// This consolidates the previously duplicated icon/name maps
let EVENT_TYPES = {};

function timelineEditor() {
  // Load initialization data from JSON block
  const initDataElement = document.getElementById('timeline-editor-init-data');
  const initData = initDataElement ? JSON.parse(initDataElement.textContent) : {};

  // Initialize EVENT_TYPES from server data
  EVENT_TYPES = initData.event_types || {
    'general': { icon: 'radio_button_checked', name: 'General' },
    'setup': { icon: 'foundation', name: 'Setup' },
    'exposition': { icon: 'info', name: 'Exposition' },
    'inciting_incident': { icon: 'flash_on', name: 'Inciting Incident' },
    'complication': { icon: 'warning', name: 'Complication' },
    'obstacle': { icon: 'block', name: 'Obstacle' },
    'conflict': { icon: 'gavel', name: 'Conflict' },
    'progress': { icon: 'trending_up', name: 'Progress' },
    'revelation': { icon: 'visibility', name: 'Revelation' },
    'transformation': { icon: 'autorenew', name: 'Transformation' },
    'climax': { icon: 'whatshot', name: 'Climax' },
    'resolution': { icon: 'check_circle', name: 'Resolution' },
    'aftermath': { icon: 'restore', name: 'Aftermath' }
  };

  return {
    // Modal and panel states
    showMetaPanel: false,
    showLinkModal: false,
    showShareModal: false,
    showFilters: false,
    showMobileFilters: false,
    linkingEventId: null,
    draggedEvent: null,

    // Search and filter state
    searchQuery: '',
    linkModalSearchQuery: '',
    selectedFilter: 'all',
    collapsedSections: {},
    contentSummaryCollapsed: {},

    // Event selection state
    selectedEvents: [],
    selectedEventId: null,
    selectedEventData: null,

    // Auto-save status
    autoSaveStatus: 'saved',

    // Event sections and filters
    eventSections: {},
    eventTypeFilters: [],
    importanceFilters: [],
    statusFilters: [],

    // Tag management
    eventTags: {},
    loadingTags: new Set(),
    timelineTagSuggestions: [],

    // Tag filtering state
    showTagFilters: false,
    showFilterSection: false,
    selectedTagFilters: [],
    tagFilterMode: 'filter',

    // Reactive properties for real-time inspector panel updates
    liveTitle: '',
    liveTimeLabel: '',
    liveEndTimeLabel: '',
    liveDescription: '',
    activeInputListeners: new Map(),

    // Timeline form data - loaded from JSON block
    timelineName: initData.timeline?.name || '',
    timelineSubtitle: initData.timeline?.subtitle || '',

    // Inline edit states
    editingTitle: false,
    editingSubtitle: false,
    tempTitle: initData.timeline?.name || '',
    tempSubtitle: initData.timeline?.subtitle || '',

    // Initialize method
    init() {
      // Initialize eventTags from server-rendered DOM data
      this.initializeEventTagsFromDOM();

      // Load timeline tag suggestions for autocomplete
      this.loadTimelineTagSuggestions();

      // Add fallback click handlers for server-rendered events
      setTimeout(() => {
        const serverEventCards = document.querySelectorAll('.timeline-event-card:not(.js-template-event-card)');

        serverEventCards.forEach((card) => {
          const eventContainer = card.closest('[data-event-id]');
          if (eventContainer) {
            const eventId = parseInt(eventContainer.getAttribute('data-event-id'));

            card.addEventListener('click', (e) => {
              if (e.alpineProcessed) return;

              const titleEl = card.querySelector('input[name*="[title]"]');
              const timeEl = card.querySelector('input[name*="[time_label]"]');
              const descEl = card.querySelector('textarea[name*="[description]"]');

              const eventData = {
                id: eventId,
                title: titleEl ? titleEl.value : 'Untitled Event',
                time_label: timeEl ? timeEl.value : '',
                description: descEl ? descEl.value : '',
                event_type: 'general',
                importance_level: 'minor',
                status: 'completed',
                tags: []
              };

              this.selectEvent(eventId, eventData);
            });
          }
        });
      }, 500);
    },

    // Initialize eventTags object from server-rendered DOM
    initializeEventTagsFromDOM() {
      const eventContainers = document.querySelectorAll('.timeline-event-container:not(.timeline-event-template)');

      eventContainers.forEach(container => {
        const eventId = container.getAttribute('data-event-id');
        if (!eventId) return;

        const tagContainer = container.querySelector(`#event-tags-${eventId}`);
        if (!tagContainer) {
          this.eventTags[eventId] = [];
          return;
        }

        const tagSpans = tagContainer.querySelectorAll('span');
        const tags = Array.from(tagSpans).map(span => span.textContent.trim());
        this.eventTags[eventId] = tags;
      });
    },

    // Load timeline tag suggestions for autocomplete
    async loadTimelineTagSuggestions() {
      const timelineId = initData.timeline?.id;
      if (!timelineId) return;

      try {
        const response = await fetch(`/plan/timelines/${timelineId}/tag_suggestions`);
        const data = await response.json();
        this.timelineTagSuggestions = data.suggestions || [];
      } catch (error) {
        console.error('Failed to load timeline tag suggestions:', error);
        this.timelineTagSuggestions = [];
      }
    },

    // Filter helper methods
    clearAllFilters() {
      this.eventTypeFilters = [];
      this.importanceFilters = [];
      this.statusFilters = [];
    },

    getFilteredEventCount() {
      const events = document.querySelectorAll('.timeline-event-container:not(.timeline-event-template)');
      let count = 0;
      events.forEach(event => {
        if (this.shouldShowEvent(event)) count++;
      });
      return count;
    },

    shouldShowEvent(eventElement) {
      const eventData = this.getEventDataFromElement(eventElement);

      // Search filter
      if (this.searchQuery && !this.matchesSearch(eventData)) {
        return false;
      }

      // Tag filter - only apply in filter mode
      if (this.tagFilterMode === 'filter' && this.selectedTagFilters.length > 0) {
        const eventId = eventElement.getAttribute('data-event-id');
        const eventTags = this.getEventTags(eventId);
        const hasSelectedTag = this.selectedTagFilters.some(selectedTag =>
          eventTags.includes(selectedTag)
        );
        if (!hasSelectedTag) return false;
      }

      // Type filter
      if (this.eventTypeFilters.length > 0 && !this.eventTypeFilters.includes(eventData.type)) {
        return false;
      }

      // Importance filter
      if (this.importanceFilters.length > 0 && !this.importanceFilters.includes(eventData.importance)) {
        return false;
      }

      // Status filter
      if (this.statusFilters.length > 0 && !this.statusFilters.includes(eventData.status)) {
        return false;
      }

      return true;
    },

    getEventDataFromElement(eventElement) {
      const title = eventElement.querySelector('input[name*="[title]"]')?.value || '';
      const description = eventElement.querySelector('textarea[name*="[description]"]')?.value || '';
      const type = eventElement.dataset.eventType || eventElement.getAttribute('data-event-type') || 'general';
      const importance = eventElement.dataset.importance || eventElement.getAttribute('data-importance') || 'minor';
      const status = eventElement.dataset.status || eventElement.getAttribute('data-status') || 'completed';

      return {
        title: title.toLowerCase(),
        description: description.toLowerCase(),
        type: type || 'general',
        importance: importance || 'minor',
        status: status || 'completed'
      };
    },

    matchesSearch(eventData) {
      const query = this.searchQuery.toLowerCase();
      return eventData.title.includes(query) || eventData.description.includes(query);
    },

    // Apply real-time filtering to timeline events
    applyEventFilters() {
      const events = document.querySelectorAll('.timeline-event-container:not(.timeline-event-template)');
      let visibleCount = 0;

      events.forEach(eventElement => {
        const shouldShow = this.shouldShowEvent(eventElement);
        const eventId = eventElement.getAttribute('data-event-id');

        if (shouldShow) {
          eventElement.style.display = 'block';
          eventElement.style.opacity = '1';
          eventElement.style.transform = 'translateY(0)';
          visibleCount++;
        } else {
          eventElement.style.opacity = '0';
          eventElement.style.transform = 'translateY(-10px)';
          setTimeout(() => {
            if (!this.shouldShowEvent(eventElement)) {
              eventElement.style.display = 'none';
            }
          }, 200);
        }

        // Update tag display for highlight mode
        if (eventId && shouldShow && this.tagFilterMode === 'highlight' && this.selectedTagFilters.length > 0) {
          this.updateMainPanelTags(eventId);
        }
      });

      this.updateEmptyState(visibleCount);
      return visibleCount;
    },

    updateEmptyState(visibleCount) {
      const eventsContainer = document.querySelector('.timeline-events-container');
      let emptyState = eventsContainer.querySelector('.search-empty-state');

      if (visibleCount === 0 && this.searchQuery.length > 0) {
        if (!emptyState) {
          emptyState = document.createElement('div');
          emptyState.className = 'search-empty-state text-center py-16';
          emptyState.innerHTML = `
            <div class="mx-auto h-16 w-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
              <i class="material-icons text-2xl text-gray-400">search_off</i>
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No events found</h3>
            <p class="text-gray-600 text-sm">
              Try adjusting your search terms or clear the search to see all events.
            </p>
            <button @click="searchQuery = ''; applyEventFilters()"
                    class="mt-4 inline-flex items-center px-4 py-2 text-sm font-medium rounded-lg text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors">
              <i class="material-icons text-sm mr-2">clear</i>
              Clear Search
            </button>
          `;
          eventsContainer.appendChild(emptyState);
        }
        emptyState.style.display = 'block';
      } else {
        if (emptyState) {
          emptyState.style.display = 'none';
        }
      }
    },

    // Link modal methods
    openLinkModal(eventId) {
      this.linkingEventId = eventId;
      this.showLinkModal = true;
      this.linkModalSearchQuery = '';
      this.selectedFilter = 'all';
      this.showMobileFilters = false;
      setTimeout(() => {
        const searchInput = document.querySelector('.link-modal-search');
        if (searchInput) searchInput.focus();
      }, 100);
    },

    closeLinkModal() {
      this.showLinkModal = false;
      this.linkingEventId = null;
      this.linkModalSearchQuery = '';
      this.selectedFilter = 'all';
      this.showMobileFilters = false;
      this.collapsedSections = {};
    },

    toggleSection(sectionKey) {
      this.collapsedSections[sectionKey] = !this.collapsedSections[sectionKey];
    },

    isSectionCollapsed(sectionKey) {
      return this.collapsedSections[sectionKey] || false;
    },

    // Content summary section management
    toggleContentSummarySection(contentType) {
      this.contentSummaryCollapsed[contentType] = !this.contentSummaryCollapsed[contentType];
    },

    isContentSummaryCollapsed(contentType) {
      return this.contentSummaryCollapsed[contentType] ?? true;
    },

    linkableContentMatches(contentName, contentType) {
      // First check filter selection
      if (this.selectedFilter && this.selectedFilter !== 'all') {
        if (this.selectedFilter === 'timeline') {
          if (contentName !== 'timeline' && contentType !== 'timeline') {
            return false;
          }
        } else {
          if (this.selectedFilter !== contentType.toLowerCase()) {
            return false;
          }
        }
      }

      // Then apply search query if present
      if (this.linkModalSearchQuery) {
        const query = this.linkModalSearchQuery.toLowerCase();
        return contentName.toLowerCase().includes(query);
      }

      return true;
    },

    linkFirstResult() {
      const visibleButtons = document.querySelectorAll('.js-link-entity-selection');
      let firstVisibleButton = null;

      for (let button of visibleButtons) {
        if (button.offsetParent !== null && !button.style.display.includes('none')) {
          firstVisibleButton = button;
          break;
        }
      }

      if (firstVisibleButton) {
        firstVisibleButton.click();
      }
    },

    // Event section management
    toggleEventSection(eventId, section) {
      const key = `${eventId}_${section}`;
      this.eventSections[key] = !this.eventSections[key];
    },

    isEventSectionOpen(eventId, section) {
      const key = `${eventId}_${section}`;
      return this.eventSections[key] || false;
    },

    // Event selection for inspector panel
    selectEvent(eventId, eventData) {
      this.selectedEventId = eventId;
      this.selectedEventData = eventData;

      this.setupLiveFormListeners(eventId);
      this.updateSidebarLinkedContent(eventId);

      if (eventData && eventData.tags) {
        this.eventTags[eventId] = eventData.tags;
        if (eventData.tags.length > 0) {
          this.updateMainPanelTags(eventId);
        }
      } else {
        this.getEventTags(eventId);
      }

      const inspectorContent = document.querySelector('.w-96 .overflow-y-auto');
      if (inspectorContent) {
        inspectorContent.scrollTop = 0;
      }
    },

    clearEventSelection() {
      this.selectedEventId = null;
      this.selectedEventData = null;
      this.clearInputListeners();
    },

    // Set up real-time input listeners for inspector panel updates
    setupLiveFormListeners(eventId) {
      this.clearInputListeners();

      const eventContainer = document.querySelector(`[data-event-id="${eventId}"]`);
      if (!eventContainer) return;

      const titleInput = eventContainer.querySelector('input[name*="[title]"]');
      const timeLabelInput = eventContainer.querySelector('input[name*="[time_label]"]');
      const endTimeLabelInput = eventContainer.querySelector('input[name*="[end_time_label]"]');
      const descriptionTextarea = eventContainer.querySelector('textarea[name*="[description]"]');

      this.liveTitle = titleInput?.value || 'Untitled Event';
      this.liveTimeLabel = timeLabelInput?.value || '';
      this.liveEndTimeLabel = endTimeLabelInput?.value || '';
      this.liveDescription = descriptionTextarea?.value || '';

      const listeners = [];

      if (titleInput) {
        const titleListener = (e) => { this.liveTitle = e.target.value || 'Untitled Event'; };
        titleInput.addEventListener('input', titleListener);
        listeners.push({ element: titleInput, type: 'input', listener: titleListener });
      }

      if (timeLabelInput) {
        const timeLabelListener = (e) => { this.liveTimeLabel = e.target.value || ''; };
        timeLabelInput.addEventListener('input', timeLabelListener);
        listeners.push({ element: timeLabelInput, type: 'input', listener: timeLabelListener });
      }

      if (endTimeLabelInput) {
        const endTimeLabelListener = (e) => { this.liveEndTimeLabel = e.target.value || ''; };
        endTimeLabelInput.addEventListener('input', endTimeLabelListener);
        listeners.push({ element: endTimeLabelInput, type: 'input', listener: endTimeLabelListener });
      }

      if (descriptionTextarea) {
        const descriptionListener = (e) => { this.liveDescription = e.target.value || ''; };
        descriptionTextarea.addEventListener('input', descriptionListener);
        listeners.push({ element: descriptionTextarea, type: 'input', listener: descriptionListener });
      }

      this.activeInputListeners.set(eventId, listeners);
    },

    clearInputListeners() {
      this.activeInputListeners.forEach((listeners, eventId) => {
        listeners.forEach(({ element, type, listener }) => {
          element.removeEventListener(type, listener);
        });
      });

      this.activeInputListeners.clear();
      this.liveTitle = '';
      this.liveTimeLabel = '';
      this.liveEndTimeLabel = '';
      this.liveDescription = '';
    },

    // Update sidebar linked content
    updateSidebarLinkedContent(eventId) {
      const sidebarContainer = document.getElementById('sidebar-linked-content');
      if (!sidebarContainer) return;

      const mainLinkedContent = document.querySelector(`#linked-content-${eventId}`);
      if (!mainLinkedContent) {
        sidebarContainer.innerHTML = `
          <div class="text-xs text-gray-500 bg-gray-50 rounded-lg p-3">
            <i class="material-icons text-xs mr-1">info</i>
            Linked content will appear here when you connect pages to this event
          </div>
        `;
        return;
      }

      const linkedCards = mainLinkedContent.querySelectorAll('.linked-content-card');

      if (linkedCards.length === 0) {
        sidebarContainer.innerHTML = `
          <div class="text-xs text-gray-500 bg-gray-50 rounded-lg p-3">
            <i class="material-icons text-xs mr-1">info</i>
            Linked content will appear here when you connect pages to this event
          </div>
        `;
        return;
      }

      let sidebarHTML = '';
      linkedCards.forEach(card => {
        const nameLink = card.querySelector('.type-badge a');
        const icon = card.querySelector('.type-badge i');
        const removeButton = card.querySelector('.remove-btn');

        if (nameLink && icon) {
          const name = nameLink.textContent.trim();
          const href = nameLink.getAttribute('href');
          const iconClass = icon.className;
          const iconText = icon.textContent;
          const removeHref = removeButton ? removeButton.getAttribute('href') : '';

          sidebarHTML += `
            <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors group">
              <div class="flex items-center min-w-0 flex-1">
                <i class="${iconClass} text-sm mr-2 flex-shrink-0">${iconText}</i>
                <a href="${href}" class="text-sm text-gray-700 hover:text-gray-900 font-medium truncate" target="_blank">
                  ${name}
                </a>
              </div>
              ${removeButton ? `
                <button onclick="unlinkFromSidebar('${removeHref}', this)"
                        class="ml-2 p-1 rounded-full text-gray-400 hover:text-red-600 hover:bg-red-50 opacity-0 group-hover:opacity-100 transition-all duration-200 flex-shrink-0"
                        title="Remove link">
                  <i class="material-icons text-xs">close</i>
                </button>
              ` : ''}
            </div>
          `;
        }
      });

      sidebarContainer.innerHTML = sidebarHTML;
    },

    // Computed properties for live form data
    get selectedEventTitle() {
      if (!this.selectedEventId) return '';
      if (this.liveTitle) return this.liveTitle;
      const input = document.querySelector(`[data-event-id="${this.selectedEventId}"] input[name*="[title]"]`);
      return input?.value || 'Untitled Event';
    },

    get selectedEventTimeLabel() {
      if (!this.selectedEventId) return '';
      if (this.liveTimeLabel !== '') return this.liveTimeLabel;
      const input = document.querySelector(`[data-event-id="${this.selectedEventId}"] input[name*="[time_label]"]`);
      return input?.value || '';
    },

    get selectedEventEndTimeLabel() {
      if (!this.selectedEventId) return '';
      if (this.liveEndTimeLabel !== '') return this.liveEndTimeLabel;
      const input = document.querySelector(`[data-event-id="${this.selectedEventId}"] input[name*="[end_time_label]"]`);
      return input?.value || '';
    },

    get selectedEventDescription() {
      if (!this.selectedEventId) return '';
      if (this.liveDescription !== '') return this.liveDescription;
      const textarea = document.querySelector(`[data-event-id="${this.selectedEventId}"] textarea[name*="[description]"]`);
      return textarea?.value || '';
    },

    get selectedEventType() {
      if (!this.selectedEventId) return 'general';
      return this.selectedEventData?.event_type || 'general';
    },

    // Event type helper methods - now using consolidated EVENT_TYPES
    getEventTypeIcon(eventId) {
      if (!eventId) return 'radio_button_checked';
      const eventType = this.selectedEventData?.event_type || 'general';
      return EVENT_TYPES[eventType]?.icon || 'radio_button_checked';
    },

    getEventTypeName(eventId) {
      if (!eventId) return 'General';
      const eventType = this.selectedEventData?.event_type || 'general';
      return EVENT_TYPES[eventType]?.name || 'General';
    },

    // Update event type and refresh timeline dot
    updateEventType(newType) {
      if (!this.selectedEventId) return;

      if (this.selectedEventData) {
        this.selectedEventData.event_type = newType;
      }

      const eventContainer = document.querySelector(`[data-event-id="${this.selectedEventId}"]`);
      if (eventContainer) {
        const form = document.createElement('form');
        form.setAttribute('method', 'POST');
        form.setAttribute('action', `/plan/timeline_events/${this.selectedEventId}`);
        form.classList.add('autosave-form');

        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
        if (csrfToken) {
          const csrfInput = document.createElement('input');
          csrfInput.type = 'hidden';
          csrfInput.name = 'authenticity_token';
          csrfInput.value = csrfToken;
          form.appendChild(csrfInput);
        }

        const methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'patch';
        form.appendChild(methodInput);

        const eventTypeInput = document.createElement('input');
        eventTypeInput.type = 'hidden';
        eventTypeInput.name = 'timeline_event[event_type]';
        eventTypeInput.value = newType;
        form.appendChild(eventTypeInput);

        submitFormWithFetch(form);

        // Update the timeline dot icon using consolidated EVENT_TYPES
        const timelineDotContainer = eventContainer.querySelector('.timeline-dot');
        const timelineDot = timelineDotContainer?.querySelector('i');
        if (timelineDot && timelineDotContainer) {
          timelineDot.textContent = EVENT_TYPES[newType]?.icon || 'radio_button_checked';
          timelineDotContainer.title = EVENT_TYPES[newType]?.name || 'General';
        }
      }
    },

    // Tag management methods
    getEventTags(eventId) {
      if (!eventId) return [];

      if (this.eventTags[eventId]) {
        return this.eventTags[eventId];
      }

      const tagContainer = document.querySelector(`#event-tags-${eventId}`);
      if (!tagContainer) {
        this.eventTags[eventId] = [];
        return [];
      }

      const tagSpans = tagContainer.querySelectorAll('span');
      const tags = Array.from(tagSpans).map(span => span.textContent.trim());
      this.eventTags[eventId] = tags;
      return tags;
    },

    loadEventTags(eventId) {
      if (!eventId) return;

      const eventContainer = document.querySelector(`[data-event-id="${eventId}"]`);
      if (!eventContainer) {
        this.eventTags[eventId] = [];
        return;
      }

      this.eventTags[eventId] = [];
    },

    addEventTag(tagName) {
      if (!this.selectedEventId || !tagName.trim()) return;

      const cleanTagName = tagName.trim();
      const existingTags = this.getEventTags(this.selectedEventId);
      if (existingTags.includes(cleanTagName)) return;

      if (!this.eventTags[this.selectedEventId]) {
        this.eventTags[this.selectedEventId] = [];
      }
      this.eventTags[this.selectedEventId].push(cleanTagName);

      if (this._tagContainerCache) {
        this._tagContainerCache.delete(this.selectedEventId);
      }

      this.updateMainPanelTags(this.selectedEventId);
      this.loadingTags.add(`${this.selectedEventId}-${cleanTagName}`);
      this.autoSaveStatus = 'saving';

      fetch(`/plan/timeline_events/${this.selectedEventId}/tags`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content'),
          'Accept': 'application/json'
        },
        body: JSON.stringify({ tag_name: cleanTagName })
      })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'success') {
          this.loadingTags.delete(`${this.selectedEventId}-${cleanTagName}`);
          this.autoSaveStatus = 'saved';
          setTimeout(() => {
            if (this.autoSaveStatus === 'saved') {
              this.autoSaveStatus = 'saved';
            }
          }, 1000);
        } else {
          throw new Error(data.message || 'Failed to add tag');
        }
      })
      .catch(error => {
        console.error('Error adding tag:', error);
        this.autoSaveStatus = 'error';
        this.loadingTags.delete(`${this.selectedEventId}-${cleanTagName}`);

        if (this.eventTags[this.selectedEventId]) {
          this.eventTags[this.selectedEventId] = this.eventTags[this.selectedEventId].filter(tag => tag !== cleanTagName);
        }

        if (this._tagContainerCache) {
          this._tagContainerCache.delete(this.selectedEventId);
        }

        this.updateMainPanelTags(this.selectedEventId);

        setTimeout(() => {
          if (this.autoSaveStatus === 'error') {
            this.autoSaveStatus = 'saved';
          }
        }, 3000);
      });
    },

    removeEventTag(tagName) {
      if (!this.selectedEventId || !tagName) return;

      const originalTags = [...(this.eventTags[this.selectedEventId] || [])];
      this.loadingTags.add(`${this.selectedEventId}-${tagName}`);

      if (this.eventTags[this.selectedEventId]) {
        this.eventTags[this.selectedEventId] = this.eventTags[this.selectedEventId].filter(tag => tag !== tagName);
      }

      if (this._tagContainerCache) {
        this._tagContainerCache.delete(this.selectedEventId);
      }

      this.updateMainPanelTags(this.selectedEventId);
      this.autoSaveStatus = 'saving';

      fetch(`/plan/timeline_events/${this.selectedEventId}/tags/${encodeURIComponent(tagName)}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content'),
          'Accept': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'success') {
          this.loadingTags.delete(`${this.selectedEventId}-${tagName}`);
          this.autoSaveStatus = 'saved';
          setTimeout(() => {
            if (this.autoSaveStatus === 'saved') {
              this.autoSaveStatus = 'saved';
            }
          }, 1000);
        } else {
          throw new Error(data.message || 'Failed to remove tag');
        }
      })
      .catch(error => {
        console.error('Error removing tag:', error);
        this.autoSaveStatus = 'error';
        this.loadingTags.delete(`${this.selectedEventId}-${tagName}`);
        this.eventTags[this.selectedEventId] = originalTags;

        if (this._tagContainerCache) {
          this._tagContainerCache.delete(this.selectedEventId);
        }

        this.updateMainPanelTags(this.selectedEventId);

        setTimeout(() => {
          if (this.autoSaveStatus === 'error') {
            this.autoSaveStatus = 'saved';
          }
        }, 3000);
      });
    },

    isTagLoading(eventId, tagName) {
      return this.loadingTags.has(`${eventId}-${tagName}`);
    },

    updateMainPanelTags(eventId) {
      if (!this._tagContainerCache) {
        this._tagContainerCache = new Map();
      }

      let tagContainer = this._tagContainerCache.get(eventId);
      if (!tagContainer) {
        tagContainer = document.querySelector(`#event-tags-${eventId}`);
        if (!tagContainer) return;
        this._tagContainerCache.set(eventId, tagContainer);
      }

      const eventTags = this.getEventTags(eventId);

      if (eventTags.length === 0) {
        if (!tagContainer.classList.contains('hidden')) {
          tagContainer.classList.add('hidden');
          tagContainer.innerHTML = '';
        }
      } else {
        const needsHighlightUpdate = this.tagFilterMode === 'highlight' && this.selectedTagFilters.length > 0;
        const currentContent = tagContainer.innerHTML;

        const newContent = eventTags.map(tag => {
          const isHighlighted = needsHighlightUpdate && this.selectedTagFilters.includes(tag);
          return `
            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium transition-colors ${
              isHighlighted
                ? 'bg-yellow-200 text-yellow-800 border border-yellow-300'
                : 'bg-gray-100 text-gray-600 border border-gray-200'
            }">
              ${tag}
            </span>
          `;
        }).join('');

        if (currentContent !== newContent) {
          tagContainer.classList.remove('hidden');
          tagContainer.innerHTML = newContent;
        }
      }
    },

    clearTagFilters() {
      this.selectedTagFilters = [];
      this.applyEventFilters();

      if (this.tagFilterMode === 'highlight') {
        Object.keys(this.eventTags).forEach(eventId => {
          this.updateMainPanelTags(eventId);
        });
      }
    },

    changeTagFilterMode(newMode) {
      this.tagFilterMode = newMode;
      this.applyEventFilters();
    },

    // Inline edit methods
    saveTitle() {
      this.timelineName = this.tempTitle;
      const form = document.querySelector('[x-ref="titleForm"]');
      if (form) {
        const input = form.querySelector('input[name="timeline[name]"]');
        if (input) {
          input.value = this.tempTitle;
        }
        this.editingTitle = false;
        submitFormWithFetch(form);
      }
    },

    saveSubtitle() {
      this.timelineSubtitle = this.tempSubtitle;
      const form = document.querySelector('[x-ref="subtitleForm"]');
      if (form) {
        const input = form.querySelector('input[name="timeline[subtitle]"]');
        if (input) {
          input.value = this.tempSubtitle;
        }
        this.editingSubtitle = false;
        submitFormWithFetch(form);
      }
    }
  };
}
