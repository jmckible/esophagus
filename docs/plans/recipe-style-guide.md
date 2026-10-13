# Recipe Style Guide

Target format uses ActionText/Trix-compatible HTML.

## Section Headings

Use `<strong>` for section labels. Standard sections:

- **Ingredients** — always present for full recipes
- **Directions** — always present for full recipes
- **Notes** — optional, for tips or source attribution
- **Variations** — optional, for alternate versions

Format: `<div><strong>Ingredients</strong></div>` on its own line, followed by content.

## Ingredients

Always use `<ul>` with `<li>` per ingredient.

```html
<div><strong>Ingredients</strong></div>
<ul>
  <li>1 cup rice</li>
  <li>1 can coconut milk</li>
</ul>
```

## Directions

Use `<ol>` with `<li>` per step when there are distinct sequential steps.
For very simple recipes (1-2 sentences), a plain `<div>` paragraph is fine.
Do NOT include manual step numbers ("1.", "2.") inside `<ol>` — the list handles numbering.

```html
<div><strong>Directions</strong></div>
<ol>
  <li>Combine ingredients in pot.</li>
  <li>Simmer covered for 18 minutes.</li>
</ol>
```

## Metadata

Recipe metadata (yield, time, servings) belongs at the top of the instructions body with bold labels, before Ingredients. Future pass will standardize these.

```html
<div><strong>Yield:</strong> 4 servings</div>
<div><strong>Time:</strong> 1 hour</div>
<div><strong>Ingredients</strong></div>
...
```

**Standard metadata fields:**
- **Yield:** — servings or quantity (e.g. "4 servings", "12 rolls", "2 loaves")
- **Time:** — total time if only one value
- **Prep time:** / **Cook time:** — when both are specified

**For this formatting pass:** strip all metadata. It will be added back in a structured way during a future content pass. Metadata to strip includes:
- "Serves X" / "Makes X servings" / "Yield: X"
- "Time: X" / "Prep time: X" / "Total time: X" / "Start to finish: X"
- "Active time: X" / "Cook time: X"

## Cleanup Rules

- Remove excessive `<br>` tags (especially trailing `<br><br>` inside list items and divs)
- Remove empty `<div><br></div>` spacer blocks between sections
- Remove empty `<div></div>` blocks
- Strip `<br>` immediately after `<strong>` section labels (e.g. `<strong>Ingredients<br></strong>` becomes `<strong>Ingredients</strong>`)

## Measurements

**Baking recipes** (bread, cake, cookies, dough): grams are primary.
- "315g bread flour" (not "2¼ cups/315 grams bread flour")
- If a recipe already has dual measurements, keep only grams
- If only volume, convert to grams

**Cooking recipes**: volume is primary, grams as optional reference.
- "2 T peanut butter (28g)"
- Don't bother with gram equivalents for small/imprecise amounts

**Informal quantities**: leave as-is.
- "1 can coconut milk", "salt and pepper", "a pinch of salt"
- "1 large onion, sliced" — don't convert produce to grams

**Formatting:**
- Use abbreviations: g, T (tablespoon), t (teaspoon), c (cup)
- Space between number and unit: "315g", "2 T", "1 t"
- Use Unicode fractions where natural: ½, ¼, ¾, ⅓, ⅔

## Content Editing

**Strip web verbosity:** Remove explanatory asides, promotional text, "Start Cooking" links, image captions, equipment affiliate links.

**Tighten steps:** Combine short sequential steps that are naturally one action. Remove over-explanation of basic techniques a home cook would know.

**Fix typos and errors.**

**"Step N" artifacts:** Strip standalone "Step 1", "Step 2" list items (web paste from NYT Cooking etc).

## What NOT to Touch

- **Empty recipes** (no content) — skip
- **Reference-only recipes** (e.g. "Food Lab cookbook", "Milk Street pg 99") — leave as-is
- **Recipe content/wording** — never change the actual text, only the HTML structure
