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
- **Turbo 8 with morphing** for smooth page transitions and form submissions
- **ActionText/Trix** for rich text recipe instructions
- **Multi-column recipe layout** via `.recipe-columns` CSS class
- **Emoji indicators**: `fire_if` (🔥), `forgotten_if` (👻) helpers

Recipe families (parent + variants) display together in the UI.

### Turbo 8 Architecture

The application uses **Turbo 8's page-level morphing** (idiomorph) for smooth navigation without full page reloads. Morphing surgically updates only changed DOM elements while preserving scroll position and unchanged state.

**Global Configuration** (`app/views/layouts/application.html.haml`):
```haml
= turbo_refreshes_with method: :morph, scroll: :preserve
```

**HTTP Caching with ETags**: Controllers use `fresh_when` to generate ETags for cacheable pages. Turbo's prefetch sends conditional requests (`If-None-Match`), and Rails returns 304 responses when content hasn't changed, making navigation instant with zero data transfer.

**Turbo Streams for Inline Editing**: Sections use a hybrid approach:
- **Edit/Cancel links** → Normal Turbo Frame navigation (GET requests with `layout: false` extraction)
- **Form submission** → Turbo Stream responses to replace frame content (avoids morphing conflicts)
- **Create/Move/Destroy** → Turbo Stream responses to update table rows or tbody

This pattern prevents issues where morphing can conflict with Turbo Frame replacements on form submissions.

**Prefetch Caveats**: Prefetch is enabled globally and works great for navigation links. However, links that return Turbo Streams (action links) should have `data: { turbo_prefetch: false }` to prevent streams from executing on hover.

## Key Files

| File | Purpose |
|------|---------|
| `app/models/recipe.rb` | Core business logic: favorites, forgotten recipes, family relationships |
| `app/models/current.rb` | CurrentAttributes for user/cookbook context |
| `app/controllers/concerns/authentication.rb` | Login enforcement |
| `app/views/layouts/application.html.haml` | Global Turbo 8 morphing configuration |
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

### Turbo Frames and Morphing
When using Turbo Frames for inline editing with global morphing enabled, form submissions can append content instead of replacing it. The solution is to return Turbo Streams from the update action:

```ruby
def update
  if @section.update(params)
    render turbo_stream: turbo_stream.replace(@section, partial: 'display', locals: { section: @section })
  else
    render turbo_stream: turbo_stream.replace(@section, partial: 'edit_form', locals: { section: @section }), status: :unprocessable_entity
  end
end
```

For actions that update multiple elements or complex table structures, replace the container:
```ruby
render turbo_stream: turbo_stream.update('table-body-id', partial: 'rows', locals: { items: @items })
```

### Turbo Stream vs Redirect Patterns
- **Turbo Streams**: Use when updating specific DOM elements (inline editing, row operations, removals)
- **Redirects with morphing**: Use for simple create/update flows that navigate to a show/index page
- **Hybrid approach**: Build full pages with layouts, use Turbo Frames for inline editing, return Turbo Streams from update actions

### Turbo Form Error Handling
Forms use standard Rails validation patterns. On validation errors, controllers render the form with `status: :unprocessable_entity`, which tells Turbo to replace the form in place while showing inline errors. For example:

```ruby
def update
  if @recipe.update(recipe_params)
    redirect_to @recipe, notice: 'Recipe updated'
  else
    render :edit, status: :unprocessable_entity
  end
end
```

### ETag Caching Strategy
Controllers add `fresh_when` to show/index actions:
- **Single record**: `fresh_when @recipe` (uses record's `cache_key`)
- **Collection**: `fresh_when @recipes.load` (loads collection and generates ETag from all records)

When records update, their `updated_at` changes, invalidating the ETag. Turbo prefetch then fetches fresh data.

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
