# Content Mentions (@-linking) System

This document describes the @-mention system used throughout Notebook.ai for linking content pages within text fields.

## Overview

The @-mention system allows users to reference their content pages (Characters, Locations, Items, etc.) by typing `@` followed by the page name. The system inserts a token like `[[Character-123]]` which gets rendered as a clickable link when displayed.

## Architecture

### Components

1. **Alpine.js Component** (`app/views/javascripts/_content_linking_alpine.html.erb`)
   - Handles all client-side interaction
   - Manages dropdown display, search, and selection
   - Triggers autosave after link insertion

2. **Data Source** (`@linkables_cache`)
   - Server-side collection of linkable content
   - Passed to client as `window.notebookLinkables`
   - Contains: name, ID, content type, color, icon

3. **Token Format**
   - Format: `[[ContentType-ID]]` (e.g., `[[Character-42]]`)
   - Processed by `ContentFormatterService` for display
   - Renders as styled, clickable links

## Implementation Guide

### 1. Basic Setup

Add the content linking partial to your view:

```erb
<%= render partial: 'javascripts/content_linking_alpine' %>
```

### 2. Textarea Configuration

Wrap your textarea in the Alpine component and add required classes:

```erb
<div x-data="contentLinking()">
  <%= text_area_tag "field[value]",
                    @value,
                    class: "js-can-mention-pages autosave-closest-form-on-change",
                    "x-ref": "editor" %>
  
  <!-- Dropdown will be inserted here by Alpine -->
</div>
```

**Required classes:**
- `js-can-mention-pages` - Identifies the field as mention-enabled
- `autosave-closest-form-on-change` - Enables autosave integration

### 3. Dropdown Template

The dropdown is automatically positioned at the cursor when `@` is typed:

```erb
<div x-show="showDropdown" class="linkables-dropdown-container absolute">
  <!-- Categorized sections with headers -->
  <template x-for="group in groupedResults">
    <!-- Section header with count and expand/collapse -->
    <!-- Items with icon, name, and type -->
  </template>
</div>
```

## Features

### Categorized Display
- Content grouped by type (Characters, Locations, etc.)
- Shows item counts per category
- Expandable sections with "+N more" button
- Sticky headers while scrolling

### Search & Filter
- Real-time filtering as user types after `@`
- Score-based search (prioritizes starts-with matches)
- Maintains categorization during search
- Empty state when no matches found

### Keyboard Navigation
- **Arrow Up/Down** - Navigate through items
- **Enter/Tab** - Select current item
- **Escape** - Close dropdown and trigger autosave
- Works seamlessly across category sections

### Visual Design
- Icon and color coding per content type
- Hover states and selection highlighting
- Max height with scrollable overflow
- Positioned dynamically at cursor location

## Data Structure

### Server-side (`@linkables_cache`)
```ruby
@linkables_cache = {
  'Character' => { 'Aragorn' => 123, 'Frodo' => 124 },
  'Location' => { 'Rivendell' => 456, 'Shire' => 457 }
}
```

### Client-side (`window.notebookLinkables`)
```javascript
[
  {
    name: "Aragorn",
    value: '[[Character-123]]',
    type: 'Character',
    color: 'bg-red-500',
    icon: 'person',
    textColor: 'text-white'
  }
]
```

## Key Functions

### `handleMentionInput()`
- Detects `@` symbol before cursor
- Extracts search term after `@`
- Triggers dropdown display
- Updates filtered results

### `updateFilteredResults()`
- Groups items by content type
- Applies search filtering with scoring
- Manages expanded/collapsed sections
- Limits items per section (default: 6)

### `selectItem(item)`
- Inserts `[[Type-ID]]` token at cursor
- Removes the `@searchterm` text
- Triggers autosave
- Hides dropdown

### `toggleSection(contentType)`
- Expands/collapses content type sections
- Shows all items vs limited set
- Updates "Show more/less" button

## Integration Points

### Autosave
- Automatically saves after link insertion (100ms delay)
- Integrates with existing `autosave.js` system
- Triggers via `change` event on textarea

### Content Rendering
- `ContentFormatterService` processes tokens server-side
- Converts `[[Type-ID]]` to HTML links
- Applies styling based on content type

## Configuration Options

```javascript
maxResults: 50,              // Total items to load
maxResultsPerSection: 6,     // Items shown per section initially
dropdownPosition: {...},     // Calculated from cursor position
expandedSections: [],        // Tracks which sections are expanded
```

## Common Issues & Solutions

### Dropdown Not Appearing
- Ensure `@linkables_cache` is populated
- Check textarea has `js-can-mention-pages` class
- Verify Alpine.js component initialization

### Cursor Position Issues
- Uses mirror element technique for accurate positioning
- Accounts for textarea scroll position
- Handles both `<textarea>` and `contenteditable` elements

### Multiple Autosave Triggers
- Throttled to prevent duplicate saves (2-second minimum)
- Checks for content changes before saving
- Coordinates with existing autosave systems

## Usage Examples

### Basic Writing Flow
1. User types: "Aragorn met Frodo at @riv"
2. Dropdown shows: Locations > Rivendell
3. User presses Enter or clicks
4. Text becomes: "Aragorn met Frodo at [[Location-456]]"
5. Autosave triggers after 100ms
6. When rendered: Shows as clickable "Rivendell" link

### Browsing All Content
1. User types just "@"
2. Sees categorized list with counts
3. Clicks "+12 more" to expand Characters section
4. Scrolls through all characters
5. Selects desired character

## Future Enhancements

- Recent/frequently used items section
- Ability to create new pages inline
- Smart suggestions based on context
- Support for custom link text
- Filtering by universe/tags
- Keyboard shortcut customization