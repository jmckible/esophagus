# Esophagus

Personal recipe management app. Rails 8.1 on Ruby 4.0, SQLite, Haml, Turbo 8 with morphing, Stimulus + importmap. Deployed with Kamal to `dell.hummingbird-ostrich.ts.net`, which is also the dev machine.

## Commands

```bash
bin/dev                  # Dev server: http://esophagus.localhost:3021
bin/rails test           # Model tests only; thin coverage, so also check pages in the running app
bundle exec rubocop      # Lint (config is permissive)
bundle exec haml-lint app/views
bin/deploy               # git push origin main && kamal deploy
bin/push-recipe 6 [12 ...] # Copy recipes' instructions from dev to production (backs up to tmp/backups)
bin/prod-read 'puts Recipe.count' # Read-only Ruby against production (query_only pragma)
kamal logs               # Production logs (alias in config/deploy.yml; follows, so pipe to head)
kamal console            # Production Rails console
```

## Dev server

The dev server is often already running. Check `http://esophagus.localhost:3021/up` before starting another. The port is fixed in `bin/dev`. Other apps on this machine use other ports: vocal holds 3000 and its worktrees 3001–3014, and stardate is on 3020. A bare `localhost:3000` is not this app.

Every page except `/login` and the public cookbook/recipe pages needs the encrypted `user_id` cookie. Without it you get a redirect to `/login`.

## Domain Model

**Cookbook** → **Recipe** ← **Cook** (log entry with date)
**Cookbook** → **Book** ← **Recipe** (printed source, with `book_page`)
**Cookbook** → **Section** (organizing recipes)
**Cookbook** → **User** (email/password auth)

**Recipe statistics** (`app/models/recipe.rb`):
- `favorite?`: 12+ cooks
- `forgotten?`: a favorite not cooked in 45+ days that is between 2.5x and 6x its expected interval. Past 6x it ages out, on the theory that you've moved on rather than forgotten it. `not_kid_friendly` recipes are never forgotten, since dropping those was deliberate.
- `family_last_cooked_on`: max across parent + variants
- `kid_status`: string enum. `nil` means not yet assessed, which is different from `not_kid_friendly`.

**Recipe variants:** Self-referential `parent_id`. Base recipes have nil parent, variants point to base. Variants can't have their own variants (enforced by validation).

## Architecture

**Current context:** `Current.user` and `Current.cookbook` via `ActiveSupport::CurrentAttributes`. Controllers scope queries with `Current.cookbook.recipes.find(id)`, which serves as the authorization check, so don't query `Recipe` unscoped in authenticated controllers.

**Public pages:** `Public::` controllers, mounted at the root path (`namespace :public, path: nil`). Cookbooks are looked up by `Cookbook#param` (a slug), not by id.

**URL shortcuts:** `/r/123` is the authenticated recipe path.

**Counter cache:** `Cook` uses `counter_cache: :cooks_count`. Never set it manually. Bulk deletes (`delete_all`) bypass callbacks and break the cache.

**Rich text:** Recipe instructions are Action Text, edited with Lexxy. Image variants need `ruby-vips` in the Gemfile, because image_processing 2.x no longer pulls it in.

**Writing recipes:** `docs/recipe-format.md` is the format for instructions: mise-grouped ingredients, quantities in the steps, timing chips, books, photos, and pushing to production. Read it before writing or rewriting a recipe.

**Styles:** "Market day", chosen on the design canvas at https://claude.ai/artifact/Jxo261hiBXYhkLg97jjwBX (rows D, F3/F4 and H are the spec).
- **Scales:** sizes, radii and tracking come from the scale tokens in `tokens.css`, shared with dashboard and stardate. A value off the scale is a scale change, not a one-off.
- **Colour:** a green-tinted daylight ground, white `.panel`s with 16px radius, and ink UI, with dark mode following the device. Tomato (`--accent`) is the only accent. Section hues come from `Section.hue_class_for` (12 oklch hues, first section unmarked). Favorite is font weight, not colour.
- **Type:** Schibsted Grotesk for everything and Fragment Mono for counts and dates, self-hosted from `app/assets/fonts`. A new font file needs a server restart (`touch tmp/restart.txt`) before Propshaft fingerprints its `url()`.
- **Pages:** pages render inside `main.page` (`content_for :page_class, 'page--narrow'` for forms) and open with `page_header`. The recipe body picks a treatment from `recipe_body_kind`: structured markup (an `ol`) gets ingredients beside directions via CSS only, while prose, link-only and book recipes read as one column or a source panel.
- **Styleguide:** `/styleguide` shows every shared pattern, so add new ones there.

**JavaScript:** Pin packages with `bin/importmap pin <pkg>`, which downloads into `vendor/javascript`. No CDN pins.

## Turbo 8 Patterns

Global morphing enabled:
```haml
= turbo_refreshes_with method: :morph, scroll: :preserve
```

**Turbo Frames + Morphing conflict:** With global morphing, form submissions inside frames can append instead of replace. Return Turbo Streams from update actions:

```ruby
def update
  if @section.update(params)
    render turbo_stream: turbo_stream.replace(@section, partial: 'display', locals: { section: @section })
  else
    render turbo_stream: turbo_stream.replace(@section, partial: 'edit_form', locals: { section: @section }), status: :unprocessable_content
  end
end
```

**When to use what:**
- Turbo Streams: inline editing, row operations, removals
- Redirects with morphing: simple create/update flows
- Links that trigger actions: add `data: { turbo_prefetch: false }`, otherwise hover prefetch runs the stream

## Deployment

Production is https://es.ophag.us, served via kamal-proxy behind a Cloudflare Tunnel. SQLite lives in the `esophagus_storage` volume.

- Kamal builds from the committed HEAD, so commit before deploying. Uncommitted changes aren't included.
- `bin/docker-entrypoint` runs `db:prepare` on boot, so migrations apply on deploy.
- Pushing to GitHub does not deploy. There's no CI. Deploy with `bin/deploy`.
