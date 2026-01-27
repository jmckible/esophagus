# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

**Esophagus** is a personal recipe management application built with Rails 8.1. Users can organize recipes into cookbooks with sections, track when they cook recipes, and identify favorites (🔥 cooked 12+ times) and forgotten recipes (👻 favorites not cooked recently).

Key features:
- Recipe variants (parent/child relationships for recipe versions)
- Multi-user cookbooks
- Cooking logs with automatic statistics
- Public sharing via read-only URLs

## Development Commands

### Setup
```bash
docker-compose up           # Start PostgreSQL
bin/rails db:prepare        # Setup/migrate database
bin/dev                     # Start Rails server (port 3000)
```

### Code Quality
```bash
bundle exec rubocop         # Lint Ruby code
bundle exec haml-lint       # Lint HAML templates
```

### Database
```bash
bin/rails db:migrate        # Run migrations
bin/rails db:rollback       # Rollback last migration
bin/rails console           # Open Rails console
```

## Architecture Overview

### Domain Model

The application centers on five core models:

**Cookbook** → **Recipe** ← **Cook** (log entry with date)
**Cookbook** → **Section** (for organizing recipes)
**Cookbook** → **User** (email/password authentication)

#### Recipe Variants Pattern
Recipes use a self-referential `parent_id` foreign key to create recipe families:
- **Base recipe**: `parent_id` is nil
- **Variant recipe**: Has a `parent_id` pointing to a base recipe

Validations ensure parents must be base recipes (no nested variants) and prevent circular references.

#### Recipe Statistics
Recipes have computed properties that drive the UI:
- `favorite?`: Recipe with 12+ cooks
- `forgotten?`: Favorite recipe not cooked in >45 days AND >2.5x the expected interval
- `expected_interval`: Recipe lifetime divided by cook count
- `family_last_cooked_on`: Max `last_cooked_on` across parent + all variants

These calculations happen in-memory using counter caches (`cooks_count`) for performance.

### Current Context Pattern

Uses `ActiveSupport::CurrentAttributes` to store the logged-in user and their cookbook:
```ruby
Current.user      # Available in controllers, views, models
Current.cookbook  # Scopes all recipe queries
```

Controllers use `Current.cookbook.recipes.find(id)` to automatically scope queries to the user's cookbook—no explicit authorization needed since each user belongs to exactly one cookbook.

### Authentication Flow

Simple email/password with `has_secure_password`. The `Authentication` concern in `ApplicationController` enforces login on all routes except `SessionsController`. Session cookies expire after 1 year.

### URL Structure

Recipes use shortened paths:
- `resources :recipes, path: 'r'` → `/r/123` instead of `/recipes/123`

Public sharing lives at the root:
- `namespace :public, path: nil` → `/cookbooks/:id` for read-only access

Nested cooks use shallow routing:
- POST `/r/123/cooks` to create a cook
- DELETE `/cooks/456` to delete

### View Patterns

- **HAML templates** with Bootstrap 5 for styling
- **Turbo-Rails** for AJAX-like interactions (form submissions without page reload)
- **ActionText/Trix** for rich text recipe instructions
- **Multi-column recipe layout** via `.recipe-columns` CSS class
- **Emoji indicators**: `fire_if` (🔥), `forgotten_if` (👻) helpers

Recipe families (parent + variants) display together in the UI.

## Key Files

| File | Purpose |
|------|---------|
| `app/models/recipe.rb` | Core business logic: favorites, forgotten recipes, family relationships |
| `app/models/current.rb` | CurrentAttributes for user/cookbook context |
| `app/controllers/concerns/authentication.rb` | Login enforcement |
| `config/routes.rb` | Routing: public namespace, nested resources, path shortcuts |
| `db/schema.rb` | Database structure: composite indexes, counter caches, self-referential FK |

## Technical Gotchas

### Counter Cache on Cooks
The `Cook` model uses `counter_cache: :cooks_count` on the `recipe` association. This means:
- Creating/destroying a Cook automatically updates `Recipe#cooks_count`
- Don't manually set `cooks_count`—Rails handles it
- Bulk operations (e.g., `Cook.delete_all`) bypass callbacks and break the cache

### Recipe Family Queries
When querying recipe families, remember that `family_last_cooked_on` is not a database column—it's computed by:
```ruby
[last_cooked_on, *variants.pluck(:last_cooked_on)].compact.max
```

This means you can't sort by `family_last_cooked_on` in SQL. Load recipes first, then sort in Ruby.

### Turbo Prefetching
`turbo:prefetch` is disabled in the layout (`data-turbo-preload="false"`) to avoid unnecessary requests. Re-enable selectively on high-traffic links if needed.

### RuboCop Configuration
The `.rubocop.yml` is extremely permissive (most cops disabled). This is intentional for a personal project. Don't expect strict style enforcement.

## Deployment

Deploys to **Fly.io** with auto-scaling to zero:
- 1 shared vCPU, 1GB RAM
- PostgreSQL via Fly.io managed service
- Release command: `bin/rails db:prepare`
- Static assets served by Propshaft

## Development Philosophy

This is a personal project without automated tests. The development style emphasizes:
- Simple, direct solutions over abstractions
- RuboCop for basic code hygiene only
- Manual testing via local server
- Iterative feature development on feature branches
