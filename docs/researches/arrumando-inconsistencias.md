# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Six distinct fixes grouped into visual and functional categories:

**Visual Fixes:**
1. **Dropdown arrow animation inconsistency** — The home product carousel dropdown and category page dropdown both use `rotate(180deg)` inline transform with identical `transition-transform duration-200` Tailwind classes. Investigation reveals the arrow animation is actually identical in both contexts. The real inconsistency is in the list visibility mechanism: home uses `classList.add/remove("hidden")` while category uses the `hidden` HTML attribute. No visual animation difference was confirmed — this item may require clarification from the user.
2. **Breadcrumb color inconsistency** — Two separate breadcrumb systems exist: (a) `breadcrumb-category.tpl` uses `text-fg-muted` for inactive crumbs and `text-secondary` for the active crumb, (b) legacy `breadcrumbs.tpl` uses bare `.crumb` classes with no active CSS color rules. The user wants consistent color usage with transparency variation. Only the category breadcrumb is properly themed.
3. **Modal/Drawer border below title** — `modal.js:78` renders an inline `border-bottom: 1px solid color-mix(in srgb, var(--primary-color) 15%, transparent)` on the modal header. This is described as visually unappealing.
4. **Modal/Drawer title and X color mismatch** — The modal uses `var(--primary-color)` for both the `<h2>` title and close button (set via inline styles in `modal.js`). The category page header uses `text-secondary` (which resolves to `var(--text-color)`) for its titles and icons. The user wants the modal title/X to match the category header color scheme (`text-secondary` / `var(--text-color)`).

**Functional Fixes:**
5. **Menu missing "Ver Todos" link** — Parent categories with children render as `<button>` accordion toggles in `menu-accordion.tpl` with no link to the parent category page. A "Ver Todos" option should be added as the first child, linking to `item.url`. The legacy `navigation-nav-list.tpl` had this pattern (line 13-25) but the current accordion menu does not.
6. **Desktop menu carousel should use Swiper** — The current desktop menu carousel (`menu-carousel.tpl` + `menu.js:68-132`) uses a custom native scroll implementation with a draggable scrollbar. It has no prev/next arrows and no seed pagination. The user wants it replaced with Swiper (same pattern as `product-carousel.js`) with arrows and seeds for visual consistency.

## 2. Assumptions (if any)

- **A-1**: For item 1 (dropdown arrow), the user may have observed the animation difference on a specific browser or the inconsistency may refer to the mechanism (class vs attribute) rather than the visual result. Need clarification — the JS logic is identical (`rotate(180deg)` on open, `""` on close) in both modules.
- **A-2**: For item 2 (breadcrumb), "usar a mesma cor, e ai sim com a transparência" means: all crumbs should use the same base color with transparency differentiating active vs inactive, rather than using two entirely different color tokens.
- **A-3**: For item 3 (modal border), the fix is to remove or significantly soften the border-bottom on the modal header.
- **A-4**: For item 4 (modal title/X color), the target color is `var(--text-color)` (i.e., the `text-secondary` token from `@theme`), matching the category header.
- **A-5**: For item 5 (Ver Todos), the link text will be a translatable string (likely "Ver todos" or "Ver todo en {name}") and will link to the parent `item.url`.
- **A-6**: For item 6 (menu carousel with Swiper), the Swiper global is available at execution time per A12. The menu carousel should adopt the same arrow and seed pagination pattern from `product-carousel.js`.

## 3. Affected Architectural Domains

| Domain | Components |
|---|---|
| **System JS modules** | `menu.js` (carousel rewrite), `modal.js` (title/X color, border) |
| **Category JS modules** | None (no JS changes needed for category dropdown if animation is already identical) |
| **Home JS modules** | None directly |
| **Templates — Navigation** | `menu-accordion.tpl` (add "Ver Todos" link), `menu-carousel.tpl` (Swiper markup) |
| **Templates — Notification** | Possibly `modal.tpl` if structural changes needed |
| **CSS** | `app.css` (possible modal header styling, menu carousel Swiper styles) |
| **Config** | `translations.txt` (new "Ver Todos" translation string if not existing) |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A12, A14, D1, S2, S3, L3, L5, R1, R3, R4, F4, F5, F9

## 5. Invariant Impact Explanation

| Invariant | Impact |
|---|---|
| **A1** | Menu carousel rewrite must stay in `__src/js/modules/system/menu.js` |
| **A2** | If carousel logic is restructured in `menu.js`, DOM guards must be preserved |
| **A3** | No new modules needed — changes are within existing module exports. If the carousel becomes a separate function, it must be exported and invoked from `index.js` |
| **A5** | No new `window.*` globals needed. Modal already uses `window.openModal` |
| **A6** | If Swiper menu carousel generates dynamic HTML with Lucide icons, `lucide.createIcons()` must be called |
| **A8** | Modal color changes must use CSS custom properties, not hardcoded values |
| **A9** | Modal state management (`data-state="open|closed"`) must remain unchanged |
| **A12** | Swiper global is guaranteed available at bundle execution time — safe to use in menu.js |
| **A14** | Any new icons (arrows, seeds) in menu carousel must use Lucide `<i data-lucide="...">` |
| **L3** | Swiper must be used via global constructor, same options pattern as `product-carousel.js` |
| **L5** | All DOM operations must remain vanilla JS — no jQuery |
| **R3** | New `js-*` class selectors for menu Swiper carousel must be documented. Existing `.js-menu-carousel`, `.js-menu-carousel-track`, `.js-menu-carousel-scrollbar-thumb` may be replaced or extended |
| **R4** | If `app.css` targets new `js-*` classes for the menu Swiper, those become part of the binding contract |
| **S3** | UI state preference order must be respected (hidden attr > data-state > aria-expanded > classList > element.style) |
| **F4** | No hardcoded theme-dependent colors in any of the fixes |

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

| Item | Risk | Rationale |
|---|---|---|
| Dropdown arrow animation | **LOW** | Possibly a non-issue — both animations are already identical in code |
| Breadcrumb colors | **LOW** | Purely template-level color class changes |
| Modal border | **LOW** | Single inline style change in `modal.js` |
| Modal title/X color | **LOW** | Single inline style change in `modal.js` |
| Menu "Ver Todos" | **LOW** | Template-only addition in `menu-accordion.tpl` |
| Menu carousel → Swiper | **MEDIUM** | Requires rewriting `menu.js:68-132` (custom scroll → Swiper), updating `menu-carousel.tpl` markup, and adding Swiper-compatible arrow/seed elements. Must preserve all existing menu functionality (mobile accordion, desktop dropdown, etc.) while replacing only the carousel portion. Risk of regressions in menu open/close behavior if carousel initialization interferes. |

**Overall Risk: MEDIUM** — driven by the menu carousel rewrite.

## 7. Likely Impacted Areas (Scoped)

### Files to modify:
- `__src/js/modules/system/modal.js` — header border style (line ~78), title/X color (lines ~77-86)
- `__src/js/modules/system/menu.js` — replace `initCarouselScrollbars()` (lines 68-132) with Swiper initialization
- `snipplets/navigation/menu-accordion.tpl` — add "Ver Todos" link for parent categories with children
- `snipplets/navigation/menu-carousel.tpl` — replace custom scroll markup with Swiper-compatible structure (`.swiper`, `.swiper-wrapper`, `.swiper-slide`) and add prev/next buttons + seed pagination container
- `__src/css/app.css` — possibly remove/adjust menu scrollbar styles (lines targeting `.js-menu-carousel-scrollbar*`), add Swiper menu carousel styles if needed

### Files potentially impacted (read-only verification needed):
- `snipplets/navigation/breadcrumb-category.tpl` — verify current color classes
- `snipplets/breadcrumbs.tpl` — verify if used and where (likely needs color classes added)
- `config/translations.txt` — check if "Ver Todos" translation exists
- `__src/js/index.js` — verify if menu.js exports change

## 8. Visual / Component Surface Impact

| Component | Visual Change |
|---|---|
| **Modal / Drawer** | Title and X button color shifts from `var(--primary-color)` to `var(--text-color)`. Border below title removed or softened. Subtle but noticeable on themes where primary and text colors differ significantly. |
| **Breadcrumb** | Unified color scheme across all pages. Currently only category page has proper theming. |
| **Menu (accordion)** | New "Ver Todos" link appears as first child under each parent category. Minor layout addition. |
| **Menu (desktop carousel)** | Replaces native scroll + custom scrollbar with Swiper carousel including prev/next arrows and seed pagination dots. Significant visual change — the navigation mechanism becomes button-driven instead of scroll-driven. |

## 9. Architectural Constraints Summary

1. **No new modules** — All changes fit within existing modules (`menu.js`, `modal.js`) and templates.
2. **Swiper is a global** — Must be used via `new Swiper()` constructor (L3), not imported. Already available per A12 load order.
3. **No hardcoded colors** — Modal color fixes must use CSS custom properties (A8, F4).
4. **Lucide for icons** — Any new arrow/nav icons must use `<i data-lucide="...">` (A14, F5). After dynamic HTML insertion, `lucide.createIcons()` must be called (A6).
5. **js-* binding contract** — Any renamed or new `js-*` classes must be synchronized across templates, JS modules, and `app.css` (R3, R4).
6. **No horizontal module imports** — Menu carousel Swiper logic must stay in `menu.js`, not import from `product-carousel.js` (R1, F9). Shared patterns must be duplicated, not abstracted.
7. **DOM guard required** — Any new or restructured exported function in `menu.js` must check for root DOM element existence as first statement (A2).
8. **Translation strings** — "Ver Todos" text should use `{{ "Ver todos" | translate }}` and be registered in `config/translations.txt` if not already present (A10).
