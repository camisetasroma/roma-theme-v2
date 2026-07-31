# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A12, A14, D1, S2, S3, L3, L5, R1, R3, R4, F4, F5, F9

### Invariant Tension Check
- **No tension detected.** All six fixes operate within existing modules and templates. The Swiper carousel rewrite in `menu.js` replaces internal logic but does not violate any invariant — Swiper is a guaranteed global (A12, L3) and the module already exists in `system/` (A1). No new modules are needed (A3). No cross-module imports are required (R1, F9). Modal color changes use CSS custom properties (A8, F4). New icons use Lucide (A14, F5).
- **Minor note on A2:** `menu.js` currently uses implicit DOM guards (optional chaining on event listeners) rather than explicit early-return guards. This is an existing pattern — the plan will not alter the guard strategy for unchanged functions, but the new Swiper carousel function section must guard against missing `.js-menu-carousel` elements.

### Risk Level
**MEDIUM** — Driven by item 6 (menu carousel rewrite from custom scroll to Swiper). All other items are LOW risk.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
No changes. No new data sources, APIs, or fetch calls are involved.

### 2.2 State / Hooks

**Modify: `__src/js/modules/system/modal.js`**
- **What:** Change the inline `color` style on the modal header `<h2>` title from `var(--primary-color)` to `var(--text-color)` (~line 80).
- **What:** Change the inline `color` style on both close button variants (with-title and floating) from `var(--primary-color)` to `var(--text-color)` (~lines 82, 86).
- **What:** Remove the `border-bottom: 1px solid color-mix(in srgb, var(--primary-color) 15%, transparent)` from the header container style (~line 78).
- **Why:** The modal title/X color should match the category page header color scheme (`var(--text-color)` = `text-secondary` token). The border is described as visually unappealing.
- **Constrained by:** A8 (must use CSS custom properties), F4 (no hardcoded colors), A9 (data-state pattern must remain unchanged).

**Modify: `__src/js/modules/system/menu.js`**
- **What:** Replace the `initCarouselScrollbars()` function (lines ~68-132) with a new `initMenuCarousel()` function that initializes Swiper on `.js-menu-carousel` elements.
- **Why:** The current custom native scroll implementation lacks prev/next arrows and seed pagination. Swiper provides these out of the box with consistent UX matching the product carousel.
- **What (Swiper config):** Use the same global `Swiper` constructor pattern as `product-carousel.js`. Configure with: `slidesPerView: "auto"`, `spaceBetween` appropriate for the card layout, navigation (prev/next buttons targeting `.js-menu-carousel-prev` / `.js-menu-carousel-next`), pagination (targeting `.js-menu-carousel-pagination`, type `"bullets"`).
- **What (Lucide reinit):** After Swiper initializes and potentially clones slides (if `loop` is used), call `lucide.createIcons()` with `typeof lucide !== "undefined"` guard (A6).
- **What (cleanup):** Remove all drag/scroll event listeners, `requestAnimationFrame` throttling, thumb width calculation, and `_scrollbarInit` idempotency logic that belong to the old custom scrollbar implementation.
- **Constrained by:** A1 (stays in `system/menu.js`), A2 (must guard with `.js-menu-carousel` existence check), A6 (Lucide reinit after dynamic HTML), A12/L3 (Swiper as global), L5 (vanilla JS only), R1/F9 (no imports from `product-carousel.js`).

### 2.3 UI / Components

**Modify: `snipplets/navigation/menu-carousel.tpl`**
- **What:** Replace the current markup structure with Swiper-compatible structure:
  - Outer wrapper keeps `.js-menu-carousel` class, adds `swiper` class.
  - `.js-menu-carousel-track` becomes `swiper-wrapper` (remove `overflow-x-auto`, snap classes, and native scroll styling).
  - Each carousel item `<a>` gets wrapped in a `<div class="swiper-slide">` (or `<a>` itself becomes the slide).
  - Add prev/next arrow buttons using Lucide icons (`<i data-lucide="chevron-left">` / `<i data-lucide="chevron-right">`) with classes `.js-menu-carousel-prev` and `.js-menu-carousel-next`.
  - Add a pagination container `.js-menu-carousel-pagination`.
  - Remove `.js-menu-carousel-scrollbar` and `.js-menu-carousel-scrollbar-thumb` elements entirely.
- **Why:** Swiper requires specific DOM structure (`.swiper` > `.swiper-wrapper` > `.swiper-slide`). The custom scrollbar is replaced by Swiper's native navigation and pagination.
- **Constrained by:** A14 (Lucide icons for arrows), R3 (new `js-*` classes become binding contract), A10 (template organization).

**Modify: `snipplets/navigation/menu-accordion.tpl`**
- **What:** For items that have subitems (the `<button>` branch), add a "Ver Todos" link as the first item inside the `.js-menu-accordion-content` panel, before the recursive `{% include %}` call.
- **What (markup):** The link should be `<a href="{{ item.url }}" class="...">{{ 'Ver todos' | translate }}</a>` styled consistently with the existing child item links (same padding, font size for the current level, with an `arrow-right` Lucide icon).
- **Why:** Parent categories with children currently render only as accordion toggles with no way to navigate to the parent category page itself.
- **Constrained by:** A10 (template include syntax), A14 (Lucide icon).

**Modify: `snipplets/breadcrumbs.tpl`**
- **What:** Add Tailwind color classes to match the `breadcrumb-category.tpl` color scheme: `text-fg-muted` for inactive crumbs/separators, `text-secondary` with `font-bold` for the active (last) crumb.
- **Why:** The legacy breadcrumb has no color styling — it relies on external CSS classes (`.crumb`, `.breadcrumbs`) that produce inconsistent results vs. the category breadcrumb.
- **Constrained by:** A8 (use theme tokens not hardcoded colors), F4.

### 2.4 Styling

**Modify: `__src/css/app.css`**
- **What:** Remove the `.js-menu-carousel-scrollbar`, `.js-menu-carousel-scrollbar-thumb`, and `.js-menu-carousel-scrollbar-thumb:active` CSS rules (lines ~375-391).
- **What:** Remove the `.js-menu-carousel-track` scrollbar-hiding rules (lines ~359-361) since Swiper does not use native scroll.
- **What:** Keep `.js-menu-carousel { position: relative; }` or adjust as needed for Swiper's absolute-positioned navigation elements.
- **What:** Add styling for the new `.js-menu-carousel-prev` and `.js-menu-carousel-next` arrow buttons (position absolute, centered vertically, with semi-transparent background using permitted `rgba(0,0,0,*)` or `rgba(255,255,255,*)` overlays).
- **What:** Add styling for `.js-menu-carousel-pagination` bullets if Swiper's default styling needs customization to match the existing seed pattern from `product-carousel`.
- **Why:** The old custom scrollbar CSS is dead code after the Swiper migration. New navigation elements need positioning and styling.
- **Constrained by:** R4 (new `js-*` CSS selectors become binding contract), A8/F4 (no hardcoded theme colors — overlays with `rgba(0,0,0,*)` or `rgba(255,255,255,*)` are permitted).

### 2.5 Assets
No new assets. All icons come from the existing Lucide library.

---

## 3. Execution Phases

### Phase 1: Modal Fixes (LOW risk, isolated)
1. Modify `modal.js` — remove `border-bottom` from header container inline style.
2. Modify `modal.js` — change `color:var(--primary-color)` to `color:var(--text-color)` on the `<h2>` title.
3. Modify `modal.js` — change `color:var(--primary-color)` to `color:var(--text-color)` on both close button variants.
4. Verify: Open modal from category filters page — confirm title and X use `--text-color`, no border below title.

### Phase 2: Breadcrumb + Menu Accordion Fixes (LOW risk, template-only)
1. Modify `snipplets/breadcrumbs.tpl` — add `text-fg-muted` to inactive crumbs and separators, `text-secondary font-bold` to active crumb. Apply `text-xs font-medium font-sans leading-4` to match category breadcrumb typography.
2. Modify `snipplets/navigation/menu-accordion.tpl` — add "Ver Todos" link as first child in accordion content panels for items with subitems. Use `{{ 'Ver todos' | translate }}` (key exists at translations.txt line 620).
3. Verify: Check breadcrumbs on non-category pages (page, cart, search, blog) for consistent styling. Check mobile menu accordion — each parent category should show "Ver Todos" as first child option.

### Phase 3: Menu Carousel Swiper Rewrite (MEDIUM risk, JS + template + CSS)
1. Modify `snipplets/navigation/menu-carousel.tpl` — replace markup with Swiper structure. Add prev/next buttons with Lucide icons. Add pagination container. Remove scrollbar elements.
2. Modify `__src/css/app.css` — remove old scrollbar CSS rules. Add new Swiper navigation/pagination styles.
3. Modify `__src/js/modules/system/menu.js` — replace `initCarouselScrollbars()` with `initMenuCarousel()` using Swiper. Include DOM guard, Lucide reinit, and proper Swiper config.
4. Verify: Desktop menu carousel renders with Swiper, prev/next arrows work, pagination dots display correctly. Mobile menu still functions (accordion, tabs, panels). No regressions in menu open/close behavior.

---

## 4. Risk Controls

### Edge Cases
- **Menu carousel with 0 categories configured:** Swiper init must be guarded — the `.js-menu-carousel` element won't exist if no categories are configured (the template wraps everything in `{% if categories | length > 0 %}`). The JS DOM guard handles this.
- **Menu carousel with 1-2 categories:** Swiper should disable navigation/pagination when all slides fit without scrolling. Use Swiper's `watchOverflow: true` or conditionally hide controls based on slide count vs visible area.
- **Modal opened without title:** The close button styling differs between with-title and no-title variants (floating absolute position). Both must be updated to `var(--text-color)`.
- **Legacy breadcrumbs with `breadcrumbs_custom_class`:** The added Tailwind classes must not conflict with externally passed wrapper classes.
- **"Ver Todos" on leaf categories:** Only categories with subitems get the accordion toggle (button branch). Leaf categories already render as direct links. The "Ver Todos" addition only applies to the button branch — no risk of duplication.
- **Translation key for "Ver todos":** Already exists at translations.txt line 620 with ES/PT/EN variants. No new translation needed.

### Regression Zones
- **Mobile menu overall functionality:** The menu.js module handles mobile accordion, tabs, panels, and the desktop carousel. The Swiper rewrite touches only the carousel portion (lines 68-132), but care must be taken not to affect event listeners or DOM queries for other menu features.
- **Modal system:** Changes are limited to inline style strings. The `data-state`, `window.openModal`/`window.closeModal` APIs, and modal open/close logic must remain untouched.
- **Category filters modal:** Uses `window.openModal()` — the modal title/X color change will affect this consumer. Verify that `var(--text-color)` looks appropriate in the filter modal context.
- **Breadcrumbs on product pages:** `page-header.tpl` includes `breadcrumbs.tpl` and is used across multiple templates. Verify no visual regressions on pages other than category.

### Strict Non-Modification Areas
- `__src/js/modules/system/modal.js` — Do NOT modify: `data-state` attribute logic, `window.openModal`/`window.closeModal` function signatures, body overflow management, modal sizing/mode logic, `contentSelector` DOM extraction.
- `__src/js/modules/system/menu.js` — Do NOT modify: mobile menu toggle logic, accordion toggle logic, tab switching logic, desktop dropdown hover logic. ONLY replace the carousel scrollbar initialization section.
- `__src/js/index.js` — Do NOT modify unless `menu.js` export name changes (it should not — `menuSystem` remains the single export).
- `snipplets/navigation/breadcrumb-category.tpl` — Do NOT modify. It is already correctly styled.
- `config/translations.txt` — Do NOT modify. The "Ver todos" key already exists.
- `static/` directory — NEVER edit directly (A4).
