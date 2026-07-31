# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Align the menu carousels (desktop dropdown and mobile menu) with the visual pattern established by the home product carousel (`home-product-carousel.tpl` + `product-carousel.js`). The menu carousels currently use Swiper's built-in pagination (small round bullets) and dark pill-shaped overlay navigation arrows. They must be updated to use:

- Custom SVG "seed" pagination indicators (same as home carousel)
- External arrow navigation buttons matching the home carousel style (Lucide `arrow-left`/`arrow-right` icons, positioned outside the swiper area)
- Consistent visual controls layout (seeds left, arrows right, below the carousel)

The menu carousel retains its own data source (settings-based category images), `slidesPerView: "auto"` behavior, and lazy initialization pattern. Only the visual controls (pagination + navigation) must be unified with the home carousel pattern.

## 2. Assumptions (if any)

- "Padrão visual dos carrosseis da home" refers specifically to the controls area: seed pagination dots and arrow buttons style/placement. It does NOT mean converting the menu carousel to use product cards, tabs, or the same `slidesPerView` configuration.
- The seed SVG shape, colors (using `--text-color` CSS variable for active, and an inactive color) and click-to-navigate behavior should be replicated from `product-carousel.js`.
- The menu carousel should keep its existing `slidesPerView: "auto"` and `spaceBetween: 0` configuration since its content (category image cards) is structurally different from product cards.
- The menu carousel should keep its lazy initialization via `requestAnimationFrame` and `_swiperInit` guard pattern.
- "Setas" (arrows) should match the home carousel style: plain Lucide icon buttons, not dark circular overlays positioned on top of slides.
- Both desktop and mobile menu carousels share the same `menu-carousel.tpl` template, so changes to the template affect both contexts.

## 3. Affected Architectural Domains

- **Template Layer**: `snipplets/navigation/menu-carousel.tpl` — carousel markup (navigation buttons, pagination container structure)
- **JS Module**: `__src/js/modules/system/menu.js` — `initMenuCarousel()` function (Swiper config, custom seed pagination rendering, arrow event binding)
- **CSS Layer**: `__src/css/app.css` — menu carousel styles (removing/replacing bullet pagination CSS, removing overlay arrow CSS, adding seed + external arrow styles)

## 4. Applicable Invariants (Codes Only)

A1, A2, A5, A6, A8, A9, A12, A14, D1, S3, S5, L3, L5, R3, R4, F4, F5

## 5. Invariant Impact Explanation

- **A1**: JS changes must stay within `__src/js/modules/system/menu.js`. No new module files needed — the carousel logic is already in menu.js.
- **A2**: `menu.js` already guards each exported function with DOM checks. The `initMenuCarousel()` is an internal function called after guard — no change needed.
- **A5**: No new cross-module communication required. The menu carousel is self-contained within `menu.js`.
- **A6**: If the seed SVG pagination is rendered via `innerHTML` (as in `product-carousel.js`), `lucide.createIcons()` is NOT needed for seeds (they are inline SVGs, not Lucide icons). However, the existing `lucide.createIcons()` call after init must be preserved for the slide content icons.
- **A8 / F4**: The seed pagination colors MUST use CSS custom properties (`--text-color`) for the active color. The inactive color in `product-carousel.js` currently uses hardcoded `#C4C4C0` — this is a KNOWN BUG (A8 item 3). The menu implementation must NOT replicate this bug; it should use a CSS variable-derived color.
- **A12 / L3**: Swiper is available as a global at execution time. The menu carousel already uses `new Swiper()` correctly.
- **A14 / F5**: Navigation arrows should use Lucide icons (`arrow-left`, `arrow-right`) matching the home carousel. No SVG snipplets.
- **D1**: JS reads carousel state from DOM. The seed count should be derived from the number of `.swiper-slide` elements (or Swiper's slide count), not from external data.
- **S3**: UI state for seeds uses `innerHTML` re-rendering (same as product-carousel.js). Arrow visibility can use `style.visibility` (mechanism 5) as done in `product-carousel.js`.
- **S5**: The menu carousel does NOT have tabs/parallel instances like product-carousel. However, the seed pagination rendering pattern should be consistent.
- **L3**: Swiper config changes (removing built-in `pagination` and `navigation` modules in favor of custom controls) must use the options pattern.
- **L5**: All DOM operations must be vanilla JS.
- **R3**: The `js-menu-carousel-prev`, `js-menu-carousel-next`, and `js-menu-carousel-pagination` selectors are already in the binding contract. No new selectors needed unless the navigation buttons are restructured (moved outside the swiper root). If buttons move, the selectors remain the same but their DOM position changes.
- **R4**: CSS targeting `js-menu-carousel-*` selectors must be updated in `app.css` to reflect the new visual pattern.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- The menu carousel exists in both desktop and mobile contexts. Visual changes affect both, and layout differences between the two contexts could cause issues.
- Removing Swiper's built-in navigation/pagination and replacing with custom controls requires careful handling of the Swiper lifecycle (especially with the lazy init pattern).
- The menu carousel uses `slidesPerView: "auto"` which means slide count visible is dynamic — seed pagination must correctly calculate how many seeds to show and which is active, which differs from the home carousel's fixed `slidesPerView` approach.
- Breaking the menu visually (especially on mobile) is explicitly called out as a concern in the feature request.

## 7. Likely Impacted Areas (Scoped)

| File | Scope of Change |
|---|---|
| `snipplets/navigation/menu-carousel.tpl` | Restructure navigation buttons and pagination container to match home carousel layout (controls bar below carousel with seeds left, arrows right) |
| `__src/js/modules/system/menu.js` | Replace Swiper built-in pagination/navigation with custom seed rendering logic and manual arrow event binding in `initMenuCarousel()` |
| `__src/css/app.css` | Remove/replace menu carousel bullet pagination styles, remove overlay arrow styles, add styles consistent with home carousel controls |

## 8. Visual / Component Surface Impact

- **Navigation arrows**: Move from dark circular overlays positioned absolutely on top of slides → plain Lucide icon buttons positioned below the carousel in a controls bar.
- **Pagination**: Replace Swiper's round bullet dots (white on dark background) → custom SVG seed shapes matching the home carousel (theme-colored, clickable).
- **Controls layout**: Add a controls bar below the carousel with `flex justify-between` layout: seeds on the left, arrows on the right (mirroring `home-product-carousel.tpl` lines 109-124).
- **Both contexts affected**: Desktop dropdown menu and mobile menu both render `menu-carousel.tpl` — the visual change applies uniformly.
- **Slide content unchanged**: The category image cards inside slides are NOT affected. Only the controls (navigation + pagination) change.

## 9. Architectural Constraints Summary

1. All JS changes confined to `__src/js/modules/system/menu.js` (`initMenuCarousel` function).
2. Template changes confined to `snipplets/navigation/menu-carousel.tpl`.
3. CSS changes confined to `__src/css/app.css` (menu carousel section).
4. Must NOT hardcode theme-dependent colors — use `--text-color` CSS variable for active seed color, and a CSS variable-derived value for inactive seed color (do NOT replicate the `#C4C4C0` bug from product-carousel.js).
5. Must use Lucide icons for navigation arrows (`arrow-left`, `arrow-right`).
6. Must preserve the lazy init pattern (`requestAnimationFrame` + `_swiperInit` guard).
7. Must preserve `slidesPerView: "auto"` and `spaceBetween: 0` Swiper configuration.
8. Must call `lucide.createIcons()` after rendering new Lucide icon markup.
9. Seed pagination must correctly track active slide index via Swiper's `slideChange` event (note: no `loop` mode in menu carousel, so `activeIndex` is used directly, not `realIndex`).
10. Changes must not break the menu's open/close behavior, accordion system, or tab panel structure in mobile.
