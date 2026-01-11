/**
 * Tag Input Component
 *
 * A reusable Alpine.js component for tag input with autocomplete functionality.
 * Used in timeline overview, inspector panel, and event cards.
 *
 * Usage:
 *   x-data="tagInputComponent({
 *     initialTags: ['tag1', 'tag2'],
 *     suggestionsUrl: '/api/tag_suggestions',
 *     onAdd: (tag) => console.log('Added:', tag),
 *     onRemove: (tag) => console.log('Removed:', tag)
 *   })"
 */

function tagInputComponent(options = {}) {
  const {
    initialTags = [],
    suggestionsUrl = null,
    staticSuggestions = [],
    onAdd = null,
    onRemove = null,
    maxSuggestions = 10
  } = options;

  return {
    currentTags: [...initialTags],
    availableSuggestions: [...staticSuggestions],
    tagInput: '',
    showSuggestions: false,
    loadingTags: new Set(),

    async init() {
      if (suggestionsUrl) {
        await this.loadSuggestions();
      }
    },

    async loadSuggestions() {
      try {
        const response = await fetch(suggestionsUrl);
        if (response.ok) {
          const data = await response.json();
          this.availableSuggestions = data.suggestions || data || [];
        }
      } catch (error) {
        console.error('Failed to load tag suggestions:', error);
      }
    },

    get filteredSuggestions() {
      const input = (this.tagInput || '').toLowerCase().trim();

      return this.availableSuggestions
        .filter(tag => {
          const matchesInput = !input || tag.toLowerCase().includes(input);
          const notAlreadyAdded = !this.currentTags.includes(tag);
          return matchesInput && notAlreadyAdded;
        })
        .slice(0, maxSuggestions);
    },

    isTagLoading(tag) {
      return this.loadingTags.has(tag);
    },

    async addTag(tagName) {
      if (!tagName || !tagName.trim()) return;

      const cleanTag = tagName.trim();

      // Don't add duplicates
      if (this.currentTags.includes(cleanTag)) {
        this.tagInput = '';
        this.showSuggestions = false;
        return;
      }

      // Add to current tags immediately for UI responsiveness
      this.currentTags.push(cleanTag);
      this.loadingTags.add(cleanTag);

      // Clear input and hide suggestions
      this.tagInput = '';
      this.showSuggestions = false;

      // Call the onAdd callback if provided
      if (typeof onAdd === 'function') {
        try {
          await onAdd(cleanTag, this.currentTags);
        } catch (error) {
          console.error('Error in onAdd callback:', error);
          // Rollback on error
          this.currentTags = this.currentTags.filter(t => t !== cleanTag);
        }
      }

      this.loadingTags.delete(cleanTag);
    },

    async removeTag(tagName) {
      if (!tagName) return;

      // Mark as loading
      this.loadingTags.add(tagName);

      // Remove from current tags
      const previousTags = [...this.currentTags];
      this.currentTags = this.currentTags.filter(tag => tag !== tagName);

      // Call the onRemove callback if provided
      if (typeof onRemove === 'function') {
        try {
          await onRemove(tagName, this.currentTags);
        } catch (error) {
          console.error('Error in onRemove callback:', error);
          // Rollback on error
          this.currentTags = previousTags;
        }
      }

      this.loadingTags.delete(tagName);
    },

    selectSuggestion(tag) {
      this.addTag(tag);
    },

    handleKeydown(event) {
      switch (event.key) {
        case 'Escape':
          this.showSuggestions = false;
          this.tagInput = '';
          break;
        case 'Enter':
          event.preventDefault();
          this.addTag(this.tagInput);
          break;
        case ',':
          event.preventDefault();
          this.addTag(this.tagInput);
          break;
      }
    },

    handleFocus() {
      this.showSuggestions = true;
    },

    handleClickAway() {
      this.showSuggestions = false;
    },

    // Utility method to update tags externally
    setTags(tags) {
      this.currentTags = [...tags];
    },

    // Utility method to get current tags
    getTags() {
      return [...this.currentTags];
    }
  };
}

// Make it available globally for Alpine.js
window.tagInputComponent = tagInputComponent;
