# DocumentEntity System Analysis

## Overview
DocumentEntity is a deep and sophisticated system that connects documents to content pages (Characters, Locations, Items, etc.) with emotional analysis and sentiment tracking. It's part of the document analysis feature and goes way beyond simple linking.

## Core Architecture

### 1. **Data Model**
```ruby
DocumentEntity < ApplicationRecord
  belongs_to :entity, polymorphic: true  # Links to any content type
  belongs_to :document_analysis          # Part of document analysis
```

### 2. **Key Relationships**
- **Document** → has_many **DocumentAnalysis** → has_many **DocumentEntities**
- DocumentEntities can be linked to any content type (polymorphic)
- Each entity tracks emotional scores (joy, sadness, fear, disgust, anger)

## How DocumentEntities Are Created

### 1. **Manual @mentions** (What we just implemented)
- User types `@` and selects a page → inserts `[[Type-ID]]` token
- `DocumentMentionJob` processes these tokens on save
- Creates DocumentEntity records linked to the mentioned pages

### 2. **AI Document Analysis**
- When user clicks "Analyze this document"
- IBM Watson NLP service extracts entities from text
- Creates DocumentEntities for detected entities (people, places, things)
- Attempts to auto-match to existing pages via `match_notebook_page!`

### 3. **Manual Linking**
- In document analysis view, users can manually link detected entities
- "Link existing" button opens modal to select from user's pages
- Can also create new pages from detected entities

## Features & Capabilities

### 1. **Emotional Analysis**
Each DocumentEntity tracks:
- **Sentiment scores**: joy, sadness, fear, disgust, anger (0-100)
- **Overall sentiment**: positive/negative/neutral with confidence score
- **Relevance score**: How important the entity is to the document

### 2. **Display Locations**

#### Document Analysis Page (`/documents/:id/analysis`)
- Cards for each entity with:
  - Image (if linked page has one)
  - Relevance score with progress bar
  - Emotional range radar chart
  - Sentiment breakdown
  - Links to view/edit the page
  - Option to remove from analysis

#### Document Edit Sidebar
- "Entities" button shows linked pages
- Quick reference with expandable previews
- Shows key attributes of linked pages

#### Content Page Associations Tab
- Shows "Mentioned in Documents" section
- Lists all documents that reference this page

### 3. **Actions Available**

#### For Linked Entities (have entity_id):
- **View**: Navigate to the content page
- **Edit**: Edit the content page
- **Remove**: Unlink from document analysis

#### For Unlinked Entities (no entity_id):
- **Create New**: Create a new page for this entity
- **Link Existing**: Select from your existing pages
- **Remove**: Delete from analysis entirely

### 4. **Background Jobs**

#### `DocumentMentionJob`
- Triggered on document save when body changes
- Scans for `[[Type-ID]]` tokens
- Creates DocumentEntities for @mentions

#### `DocumentEntityAnalysisJob`
- Triggered when entity is added manually
- Calls IBM Watson to analyze sentiment
- Updates emotional scores

## API & Controllers

### DocumentsController Actions:
- `link_entity`: Links detected entity to existing page or creates new
- `destroy_document_entity`: Removes entity from analysis
- `unlink_entity`: Removes link between document and page

### Routes:
```ruby
documents do
  member do
    get :analysis
    post :queue_analysis
    delete 'destroy_entity/:id' => 'documents#destroy_document_entity'
    post :link_entity
  end
end
```

## Security & Permissions
- Only document owner can link/unlink entities
- Linked pages must belong to document owner
- Analysis features require premium plan
- @mentions only work with user's own content

## Integration Points

### 1. **ContentFormatterService**
- Processes `[[Type-ID]]` tokens in document body
- Renders them as styled, clickable links

### 2. **DocumentAnalysisService**
- Creates placeholder analysis when needed
- Manages relationship between documents and entities

### 3. **IBM Watson Service**
- Extracts entities from text
- Provides sentiment analysis
- Calculates relevance scores

## The Full Flow

1. **User writes document** with @mentions → `[[Character-123]]` tokens
2. **On save**, `DocumentMentionJob` creates DocumentEntities
3. **Optional**: User clicks "Analyze" → Watson extracts more entities
4. **Entities appear** in analysis view with emotions/sentiment
5. **User can**:
   - Link unmatched entities to existing pages
   - Create new pages from entities
   - Remove entities they don't want
6. **Linked pages** show up in:
   - Document's entity sidebar
   - Page's "Mentioned in Documents" section
   - Analysis view with full emotional data

## What Makes This Powerful

This isn't just "linking pages" - it's:
- **Contextual understanding**: How entities relate emotionally to the document
- **Bi-directional references**: Documents know their entities, pages know their mentions
- **Sentiment tracking**: Understanding the emotional tone around each entity
- **Auto-matching**: AI tries to match extracted text to existing pages
- **Quick reference**: Instant access to linked page data while editing
- **Analysis insights**: Visual representation of entity emotions and relevance

The system essentially creates a knowledge graph of your world-building content with emotional and contextual metadata.