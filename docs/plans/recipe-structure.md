# Recipe structure

Turn recipes into a shape the app can lay out, and eventually into a format built for cooking: mise first, then sequenced steps.

## Why

The redesign's recipe page (canvas row D: https://claude.ai/artifact/Jxo261hiBXYhkLg97jjwBX) has two treatments:

- **Structured:** ingredients beside numbered directions, with notes and sub-recipes such as sauces below. It's rendered with CSS from the existing Trix markup, so no new fields are needed.
- **Unstructured:** one reading column. When the recipe is only a pointer, the source link is the emphasis.

The page is only as good as the share of recipes that are structured. As of 2026-10-12 (dev copy of prod, 220 recipes):

| Shape | Count |
|---|---|
| Headings + `ul` ingredients + `ol` directions | 62 |
| `ul` + `ol`, no headings | 3 |
| One list only | 27 |
| Prose only | 96 |
| Empty, with link | 15 |
| Empty, no link | 17 |

The 62 come from formatting pass 1 (March 2026), which hasn't been pushed to production. The current target format is `docs/plans/recipe-style-guide.md`, copied from the gitignored `tmp/` where pass 1 left it.

## Structured vs unstructured is a rendering decision, not a field

Detect structure from the markup (an `ol` directions list exists) rather than storing a flag. A recipe becomes structured by being rewritten, and the page follows. Revisit this if the mise format below needs something markup can't carry.

## Work, roughly in dependency order

1. **Decide the target format first.** Jordan has an "optimized" way of writing recipes for prepping mise and sequencing steps. Design it before converting anything, or every recipe gets reformatted twice. First draft, on American Chop Suey (`/r/6`, dev only so far):
   - **The ingredient list is the mise.** Ingredients are grouped by the moment they enter the pan (one group, one bowl), in the order they're used. Things measured together share a group (Worcestershire + stock). Splits are spelled out at prep ("1 T parsley" in Spices and again in Finish).
   - **Steps name groups** ("add aromatics"), so cooking never sends you back to the list.
   - **Every quantity appears once in the directions, at the moment it's measured.** On a phone the ingredient list scrolls away, and the directions are what you read at the stove. Prep steps lead with the group in bold ("**Aromatics:** finely dice ½ large onion…") and carry the quantities. Once the heat is on, steps name groups and only give amounts for things measured on the spot (oil, butter, beef from the pack). The ingredient list becomes the check before you start: shopping, pantry, how many bowls.
   - **Prep vs cook is a line, not yet a structure.** Recipe 6 went from 7 steps to 11, with the heat going on at step 7. A "Cook" heading or divider there might help scanning, but a second `ol` would break the desktop grid (only the first `ol` sits beside the ingredients). Revisit after cooking from it.
   - **Background work leads.** The noodle soak is "Start first." Untested on a recipe with real parallel tracks (sauce while meat rests); try one before converting in bulk.
   - **Markup carries it; no new fields.** Lexxy (replaced Trix 2026-10-13) writes `h2` section headings, and a group is `<li><strong>Label</strong><ul>…</ul></li>`. It has to be one nested `ul`, not a run of `ul`s: the structured grid puts the directions `ol` in a single row, so separate lists would push the steps apart.
2. **Import link-only recipes.** Fetch the 15 empty-with-link recipes from their source and rewrite them into the target format.
3. **Convert prose and one-list recipes.** Some prose recipes are legitimately notes (Salmon is a list of approaches), so leave those unstructured.
4. **Model book references as a source.** About 90 stubs are pointers to physical cookbooks ("Food Lab", "Milk Street Tuesday"). A source field (book + page) fits them better than instruction text.
5. **Photos.** Built 2026-10-13: `Recipe#photo` shows in the recipe header per canvas G2, `bin/rails recipes:photo ID= URL=` attaches the source's `og:image` (found through the browser, since sites like Serious Eats block plain fetches), and `bin/push-recipe` carries it to production. Still to do: photos on index cards (canvas G1) and the public recipe page.

## Data quirks found along the way

- 21 variants are filed in a different section than their parent. The index shows variants under their parent, so a variant's own `section_id` is effectively dead. Either make variants inherit their parent's section, or drop the column for variants.
- The forgotten flag conflates *forgotten* with *retired*: Pasta Frittata hasn't been cooked since 2020. See `meal-planning.md`.
