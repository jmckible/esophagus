# Meal planning

Suggest the next handful of dinners as a coherent menu rather than a list of things you've neglected.

## Why

The index serves two jobs: browsing for ideas, and jumping to tonight's recipe. Neither answers "what should we cook this week?" A forgotten-favorites callout was tried on the redesign canvas and rejected. Neglect alone doesn't make a menu.

The idea instead is a suggested set of about 5 meals that fits a pattern. For example: a rice dish, a pasta, a vegetarian, a favorite, and something not cooked in a while. It would probably live on its own page, possibly as a spinner or randomizer where you re-roll one slot and keep the rest.

## What exists

- `kid_status` on Recipe (nil = not assessed).
- `favorite?` (12+ cooks) and `forgotten?` (a favorite overdue at 2.5–6× its usual interval, aging out after 6×).
- Sections. They're exclusive, so they can't express "rice" and "latin" at once.
- The calendar, which shows past cooks but was never used for planning.

## What a menu needs

- **Tags.** Slots are categories like rice, pasta and vegetarian, and a dish belongs to several (tacos are ground meat and latin). Sections can't do this. This was agreed 2026-08-15 and not yet built.
- **Retire.** A way to say "we've moved on" so retired recipes stop counting as forgotten (Pasta Frittata).
- **Slot rules.** Each slot is a predicate over tags, favorite or forgotten status, kid status and recency. Repeats within a week are excluded.
- **Seasonality**, maybe. Cooking volume swings from ~87 cooks a month in summer to ~139 in winter, and dish mix probably shifts too.

## Data findings (prod snapshot, 2026-08-15)

- Recent cooking is concentrated: 96 cooks in 180 days over only 33 distinct recipes, 61% of them favorites.
- The never-cooked backlog (38) is almost all Dessert, Bread, Side and Components. A "something new" dinner slot needs new recipes coming in, not the backlog.

## Open questions

- Does accepting a suggested menu log anything, such as planned cooks, or is it purely advisory?
- Is the pattern fixed, or configured per week?
- How does kid status weigh in: filter, or prefer?
