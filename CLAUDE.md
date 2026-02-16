# Esophagus

Personal recipe management app. Rails 8.1, PostgreSQL, Turbo 8 with morphing.

## Commands

```bash
docker-compose up       # Start PostgreSQL
bin/dev                 # Rails server (port 3000)
bundle exec rubocop     # Lint (config is permissive)

fly deploy              # Production deploy
fly logs --app esophagus | head -100  # View logs (fly logs runs forever without head)
```

## Domain Model

**Cookbook** → **Recipe** ← **Cook** (log entry with date)
**Cookbook** → **Section** (organizing recipes)
**Cookbook** → **User** (email/password auth)

**Recipe statistics:**
- `favorite?`: 12+ cooks
- `forgotten?`: Favorite not cooked in >45 days AND >2.5x expected interval
- `family_last_cooked_on`: Max across parent + variants (computed in Ruby, not SQL)

**Recipe variants:** Self-referential `parent_id`. Base recipes have nil parent, variants point to base. No nested variants.

## Architecture

**Current context:** `Current.user` and `Current.cookbook` via `ActiveSupport::CurrentAttributes`. Controllers scope queries with `Current.cookbook.recipes.find(id)` - no explicit authorization needed.

**URL shortcuts:**
- `/r/123` instead of `/recipes/123`
- `/cookbooks/:id` for public read-only access

**Counter cache:** `Cook` uses `counter_cache: :cooks_count`. Don't manually set it. Bulk deletes bypass callbacks and break the cache.

## Turbo 8 Patterns

Global morphing enabled:
```haml
= turbo_refreshes_with method: :morph, scroll: :preserve
```

**ETags:** Controllers use `fresh_when` for caching. Turbo prefetch sends conditional requests, Rails returns 304 when unchanged.

**Turbo Frames + Morphing conflict:** Form submissions with global morphing can append instead of replace. Solution: return Turbo Streams from update actions:

```ruby
def update
  if @section.update(params)
    render turbo_stream: turbo_stream.replace(@section, partial: 'display', locals: { section: @section })
  else
    render turbo_stream: turbo_stream.replace(@section, partial: 'edit_form', locals: { section: @section }), status: :unprocessable_entity
  end
end
```

**When to use what:**
- Turbo Streams: inline editing, row operations, removals
- Redirects with morphing: simple create/update flows
- Action links: add `data: { turbo_prefetch: false }` to prevent streams executing on hover

## Key Files

| File | Purpose |
|------|---------|
| `app/models/recipe.rb` | Favorites, forgotten, family relationships |
| `app/models/current.rb` | CurrentAttributes for user/cookbook |
| `app/controllers/concerns/authentication.rb` | Login enforcement |
| `config/routes.rb` | Public namespace, nested resources, path shortcuts |

## Deployment

Deploys to production are automatically triggered by pushing the `main` branch to GitHub via an Action. Production is at https://es.ophag.us
