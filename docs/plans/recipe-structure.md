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

The 62 come from formatting pass 1 (March 2026), pushed to production 2026-10-14 after checking none had been edited there since. The current target format is `docs/plans/recipe-style-guide.md`, copied from the gitignored `tmp/` where pass 1 left it.

## Structured vs unstructured is a rendering decision, not a field

Detect structure from the markup (an `ol` directions list exists) rather than storing a flag. A recipe becomes structured by being rewritten, and the page follows. Revisit this if the mise format below needs something markup can't carry.

## Work, roughly in dependency order

1. **Decide the target format first.** Jordan has an "optimized" way of writing recipes for prepping mise and sequencing steps. Design it before converting anything, or every recipe gets reformatted twice. First draft, on American Chop Suey (`/r/6`, dev only so far):
   - **The ingredient list is the mise.** Ingredients are grouped by the moment they enter the pan (one group, one bowl), in the order they're used. Things measured together share a group (Worcestershire + stock). Splits are spelled out at prep ("1 T parsley" in Spices and again in Finish).
   - **Steps name groups** ("add aromatics"), so cooking never sends you back to the list.
   - **Every quantity appears once in the directions, at the moment it's measured.** On a phone the ingredient list scrolls away, and the directions are what you read at the stove. Prep steps lead with the group in bold ("**Aromatics:** finely dice ½ large onion…") and carry the quantities. Once the heat is on, steps name groups and only give amounts for things measured on the spot (oil, butter, beef from the pack). The ingredient list becomes the check before you start: shopping, pantry, how many bowls.
   - **Long recipes get timing targets, worked back from a ready time.** Built on Pulled Pork (`/r/8`, Smitten Kitchen's crispy oven version). A step that takes clock time opens with its duration as inline code (Lexxy's Code button): `15 min`, `~5 h` (about), `75–90 min` (a range, planned at the top), `6 h+` (at least; shows as "Night before" when it lands before 7 AM), `≤ 1½ h` (a hold, planned at half so the roast can finish early or late; shows the window), `+1 h` (that far into the previous timed step, e.g. the first baste). A step without a chip runs alongside the previous timed step ("While it rests"). `timeline_controller.js` adds a "Ready at" input (default 5:30 PM, remembered per device) and labels each step with its clock time; recipes without chips are unchanged.
   - **Prep vs cook is a line, not yet a structure.** Recipe 6 went from 7 steps to 11, with the heat going on at step 7. A "Cook" heading or divider there might help scanning, but a second `ol` would break the desktop grid (only the first `ol` sits beside the ingredients). Revisit after cooking from it.
   - **Background work leads.** The noodle soak is "Start first." Parallel tracks tried on Biang Biang Noodles (`/r/392`): sauce and aromatics are chip-less steps placed after the dough's `1 h+` rest, so they take its time. That reads naturally and needed no new convention.
   - **Make-ahead is text, not timeline.** The Biang Biang dough rests 1 hour or up to 3 days in the fridge. The timeline plans the minimum (same afternoon); "or refrigerate up to 3 days" lives in the step. A multi-day plan would need a date, not a clock time; not worth building until a recipe is routinely made across days.
   - **Markup carries it; no new fields.** Lexxy (replaced Trix 2026-10-13) writes `h2` section headings, and a group is `<li><strong>Label</strong><ul>…</ul></li>`. It has to be one nested `ul`, not a run of `ul`s: the structured grid puts the directions `ol` in a single row, so separate lists would push the steps apart.
2. **Import link-only recipes.** Done 2026-10-14 for the 14 fetchable ones. Kalbi (`/r/400`, archive.ph) still needs the browser.
3. **Convert prose and one-list recipes.** Done 2026-10-14: 57 recipes converted, pushed with source photos; production has 123 structured. Jordan's own changes and notes were folded in or kept under a Notes heading. Left unstructured on purpose: hubs of variations (Pizza, Salmon, Chili, Tacos, Drumsticks, Grilled Thighs), cookbook pointers (step 4), 17 recipes with no text or link, and a few fragments (Lo Mein's noodle ratio, ingredient-only formulas like Ramen Noodles).
4. **Model book references as a source.** Built 2026-10-14: `Book` (per cookbook, unique name) plus `recipes.book_id` and `book_page`. The form takes a book name with autocomplete and creates books as typed; the page shows a "Recipe in" panel for recipes without structured instructions, with leftover notes below. 34 recipes moved; the old pointer text is gone and the remaining notes kept. Not moved: references inside hubs and variations ("Mushroom – Smitten Kitchen book 2 page 128"), and "Cookbook page 70" (which book?). The real count was about 40, not the ~90 first estimated.
5. **Photos.** Built 2026-10-13: `Recipe#photo` shows in the recipe header per canvas G2, `bin/rails recipes:photo ID= URL=` attaches the source's `og:image` (found through the browser, since sites like Serious Eats block plain fetches), and `bin/push-recipe` carries it to production. Still to do: photos on index cards (canvas G1) and the public recipe page.

## Data quirks found along the way

- 21 variants are filed in a different section than their parent. The index shows variants under their parent, so a variant's own `section_id` is effectively dead. Either make variants inherit their parent's section, or drop the column for variants.
- The forgotten flag conflates *forgotten* with *retired*: Pasta Frittata hasn't been cooked since 2020. See `meal-planning.md`.
