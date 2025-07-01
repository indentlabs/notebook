# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Setup and Installation
```bash
# Install dependencies
bundle install

# Install JavaScript dependencies
yarn install

# Setup database
rake db:setup  # Creates and seeds the database
rake db:migrate  # Apply all pending migrations
```

### Development
```bash
# Start the Rails server
rails server
# Or
rails s

# Start Sidekiq for background jobs
bundle exec sidekiq

# Start the development server with both web and worker processes
RAILS_GROUPS=web,worker rails server
```

### Testing
```bash
# Run all tests
rails test

# Run a specific test file
rails test path/to/test.rb

# Run specific test
rails test path/to/test.rb:LINE_NUMBER
```

### Database Operations
```bash
# Reset database (CAUTION: Destroys all data)
rake db:reset

# Migrate database
rake db:migrate

# Rollback last migration
rake db:rollback
```

### Asset Management
```bash
# Compile assets
rails assets:precompile
```

### Deployment
```bash
# Run in production mode
RAILS_ENV=production rails server
```

## Architecture Overview

Notebook.ai is a Rails application for writers and roleplayers to create and manage fictional universes and their components. The application follows standard Rails MVC architecture with some specific design patterns.

### Key Concepts

1. **Content Types**: The application revolves around different content types like Universe, Character, Location, etc. Each represents a different entity within a user's fictional world.

2. **Content Pages**: All content types inherit from a shared ContentPage concern, which provides common functionality like attributes, privacy settings, and image uploads.

3. **Universes**: The top-level organizational unit. Users create universes and add various content types within them.

4. **Attributes System**: The application uses a flexible attributes system to store custom fields for each content type, allowing for extensibility without schema changes.

5. **Privacy & Sharing**: Content can be private, public, or shared with specific collaborators.

### Core Components

#### Content Structure
- **Universe**: The top-level container for all world-building elements
- **Character**, **Location**, **Item**: Core content types that are available to all users
- **Premium Content Types**: Many additional content types (Creature, Planet, Religion, etc.) available to premium users

#### Key Modules and Concerns
- `BelongsToUniverse`: Associates content with universes
- `IsContentPage`: Provides shared content page functionality
- `HasAttributes`: Handles dynamic attributes for content types
- `HasPrivacy`: Manages content privacy settings
- `HasImageUploads`: Handles image attachment functionality
- `ContentPage`: Base behavior for all content pages

#### Background Processing
- Sidekiq is used for background job processing
- Document analysis, exports, and other intensive tasks run asynchronously

#### Data Flow
1. Users create universes to contain their fictional worlds
2. Within universes, users create various content types (characters, locations, etc.)
3. Content types can be linked together with relationships (e.g., a character can be linked to locations)
4. Users can collaborate on universes, allowing multiple people to contribute to the same world

### Directory Structure

Beyond the standard Rails structure, notable directories include:
- `app/models/page_types/`: Contains all content type models
- `app/models/page_groupers/`: Contains relationship models between content types
- `config/attributes/`: Configuration for content type attributes
- `app/authorizers/`: Authorization logic for content access

### Key Files
- `config/initializers/content_types.rb`: Defines all available content types
- `app/models/content_page.rb`: Base functionality for all content pages
- `app/controllers/content_controller.rb`: Base controller for all content types

## Content Type System

The application uses a content type system with these types of pages:
- Universe (top-level container)
- Character, Location, Item (core types)
- Many premium content types like Creature, Planet, Religion, etc.

Creating a new content type requires following the process in `docs/content_types.md`.