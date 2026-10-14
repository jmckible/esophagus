# Recipe format

How to write a recipe's instructions so the recipe page can lay them out and the cook can follow them at the stove. Applies to anyone editing recipes: Jordan in the Lexxy editor, or Claude writing HTML.

## Structured or not is decided by the markup

There's no flag. `recipe_body_kind` looks at the instructions: an `ol` means structured (ingredients beside numbered directions on desktop, stacked on a phone); other text is prose (one reading column); none at all shows the source (link or book). A recipe becomes structured by being rewritten.

Leave these unstructured on purpose:

- **Hubs:** a list of variations or approaches (Pizza, Salmon, Chili, Tacos). They link out to the real recipes.
- **Cookbook recipes:** set the Book and Page fields instead of writing "Milk Street pg 77". Instructions then hold only Jordan's notes, if any.
- **Formulas and fragments:** a dough ratio or ingredient list with no method (Ramen Noodles, Lo Mein).

## Shape

```html
<h2>Ingredients</h2>
<ul>
  <li><strong>Rub</strong><ul><li>3 T kosher salt</li>…</ul></li>
  <li><strong>Slaw</strong><ul>…</ul></li>
</ul>
<h2>Directions</h2>
<ol>
  <li><code>6 h+</code> <strong>Rub:</strong> combine 3 T salt, …</li>
  …
</ol>
<p>Optional closing line: serving, yield, storage.</p>
<h2>Notes</h2>
<p>Jordan's notes that don't belong in a step.</p>
```

- **One top-level `ul`, one `ol`.** The desktop grid puts the first `ol` beside the ingredients; a second list breaks the layout. Group ingredients with a nested `ul` inside one list, never a run of separate lists.
- No `div`, `br`, or empty elements; no step numbers in the text.

Reference recipes: Pulled Pork (`/r/8`, long and timed), Biang Biang Noodles (`/r/392`, make-ahead with prep during a rest), American Chop Suey (`/r/6`, prep-heavy). `/styleguide` shows the markup rendered.

## The ingredient list is the mise

- Group ingredients by the moment they go in: one group, one bowl, in order of use. Name groups by role (Aromatics, Spices, Sauce, Dough, Finish, Serve). Things measured together share a group; an ingredient split across moments appears in each.
- A one-bowl recipe can use a flat `ul` with no groups.
- The list is the check before you start: shopping, pantry, how many bowls.

## Every quantity appears once in the directions, when it's measured

On a phone the ingredient list scrolls away, and the directions are what you read at the stove.

- Prep steps lead with the group in bold and carry the quantities: `<strong>Sauce:</strong> whisk 60 g soy, 20 g oyster sauce…`.
- Once the heat is on, steps name groups ("add the aromatics") and give amounts only for things measured on the spot (oil, butter, meat from the pack).
- Background work leads ("Start first: soak the noodles").

## Timing chips

A step that takes clock time opens with its duration in inline code (Lexxy's Code button). `timeline_controller.js` then adds a "Ready at" input (default 5:30 PM, remembered per device) and labels every step with its clock time, worked back from dinner.

| Chip | Meaning | Shown as |
|---|---|---|
| `15 min`, `1½ h` | takes that long | clock time |
| `~5 h` | about that long | clock time |
| `75–90 min` | a range, planned at the top | clock time |
| `6 h+` | at least that long (brines, overnight rests) | "Night before" when it lands the day before, or before 7 AM |
| `≤ 1½ h` | a hold that can flex, planned at half | a window, "3:40–5:10 PM" |
| `+1 h` | that far into the previous timed step (first baste) | clock time |
| none | happens alongside the previous timed step | that step's time |

- Chipped durations should add up to the real total, including passive time: preheating, simmering, resting.
- Put prep that fits inside a wait right after the wait's step, without a chip ("Sauce: while the dough rests…").
- Steps that land before the ready day show it: "Day before, 1:30 AM", "Start 2 days before at 11:30 PM".
- Make-ahead ranges ("rest 1 hour or up to 3 days") are text. The timeline plans the minimum.
- Recipes without chips are unchanged; don't chip trivial steps.

## Units and voice

- T, t, c, lb, oz, g; ° without F ("375°"); Unicode fractions (½ ¼ ¾ ⅓ ⅔ ⅛).
- Baking: grams first. Cooking: volume first.
- Terse imperative. Cut headnotes and source chatter; keep doneness cues ("until it collapses and yields easily to a fork").
- No yield or time metadata lines; a closing `<p>` can say "A full batch is 3–4 portions."

## Jordan's changes win

When rewriting from a source, Jordan's own quantities, substitutions and notes are his real practice: use his amounts in the ingredients and steps, and keep any remaining notes under Notes. Never drop them. Where a note conflicts with the steps or a quantity is a guess, say so in Notes rather than silently picking.

## Source, photo, production

- **Link:** when a source redirects, store the final URL.
- **Book:** the Book and Page fields. Book names autocomplete and new names create a book.
- **Photo:** `bin/rails recipes:photo ID= URL=` attaches the source's `og:image` (fetch the page in the browser when the site blocks curl). Photos appear on the recipe page header only, never in the index.
- **Production:** edit on dev, then `bin/push-recipe <id>...` copies instructions, link, book and photo, skipping any recipe edited on production since dev's copy and backing up what it replaces to `tmp/backups`. Check production with `bin/prod-read` first when the dev copy is old.
