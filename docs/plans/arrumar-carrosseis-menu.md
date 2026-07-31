# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A5, A6, A8, A12, A14, D1, S3, S5, L3, L5, R3, R4, F4, F5

### Invariant Tension Check

- **A8 / F4 tension with product-carousel.js pattern**: The home carousel uses hardcoded `#C4C4C0` for inactive seed color (known bug A8 item 3). The menu carousel implementation MUST NOT replicate this bug. Inactive seed color will use `color-mix(in srgb, var(--text-color) 40%, transparent)` or equivalent CSS variable-derived approach.
- **R3 tension**: Current `js-menu-carousel-prev` and `js-menu-carousel-next` selectors are in the binding contract. These selectors will be preserved but their DOM position will move from inside the swiper root to a new controls bar below it. The JS selector queries must be scoped correctly after the move.
- **No invariant violations required.** All changes fit within the existing architecture.

### Risk Level

**MEDIUM** — Menu carousel renders in both desktop dropdown and mobile panel contexts. Visual restructuring (moving controls outside swiper root) affects both. The `slidesPerView: "auto"` mode means seed count calculation must account for dynamic visible slide counts differently than the home carousel's fixed `slidesPerView`.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

No changes. The menu carousel data source (settings-based category images) remains unchanged. No new data fetching or server interaction.

### 2.2 State / Hooks

No new modules or cross-module communication. All changes are within `menu.js`'s existing `initMenuCarousel()` closure.

**What will be modified:**
- `__src/js/modules/system/menu.js` — `initMenuCarousel()` function

**Changes:**
1. Remove Swiper's built-in `navigation` and `pagination` config objects from the `new Swiper()` call
2. Add a `renderMenuPagination(swiper, container)` internal helper function that:
   - Reads `swiper.slides.length` (real slide count — no loop mode, so no duplication concern)
   - Generates seed SVG `<span>` elements using the same SVG path as `product-carousel.js`
   - Active seed color: read from `getComputedStyle(document.documentElement).getPropertyValue("--text-color")`
   - Inactive seed color: use `color-mix(in srgb, var(--text-color) 40%, transparent)` via a CSS class or computed style (NOT hardcoded hex) — this avoids replicating the A8 bug
   - Sets `innerHTML` of the pagination container
   - Binds click listeners on each seed to call `swiper.slideTo(index)`
3. Add `slideChange` event handler in Swiper `on:` config that calls `renderMenuPagination()` to re-render seeds with updated active index
4. Bind manual click listeners on prev/next buttons: `swiper.slidePrev()` / `swiper.slideNext()`
5. Add controls visibility logic: hide arrows when total slides fit in viewport (use `swiper.isBeginning && swiper.isEnd` or Swiper's `watchOverflow` state)
6. Handle disabled state for arrows: when `swiper.isBeginning`, visually dim/hide prev; when `swiper.isEnd`, visually dim/hide next (since there is no loop mode)
7. Preserve the existing `_swiperInit` guard and `requestAnimationFrame` lazy init pattern
8. Preserve the existing `lucide.createIcons()` call after init (needed for arrow Lucide icons in the new template markup)

**Why:** Swiper's built-in pagination renders bullet dots that cannot be styled as seed SVGs. Swiper's built-in navigation positions arrows as overlays. Both must be replaced with manual control to match the home carousel visual pattern.

**Constrained by:** A1 (changes in `__src/js/modules/system/`), A6 (lucide.createIcons after Lucide markup), L3 (Swiper global usage pattern), L5 (vanilla JS only), D1 (read state from DOM), S3 (prefer innerHTML rendering pattern consistent with product-carousel), F4 (no hardcoded theme colors)

### 2.3 UI / Components

**What will be modified:**
- `snipplets/navigation/menu-carousel.tpl`

**Changes:**
1. Move prev/next buttons and pagination container OUT of the `.js-menu-carousel.swiper` div
2. Create a controls bar below the swiper container matching the home carousel pattern:
   - Outer `div` with flex layout, items-center, justify-between, margin-top
   - Left side: `.js-menu-carousel-pagination` container (empty — JS fills with seeds)
   - Right side: flex container with two buttons:
     - `.js-menu-carousel-prev` with `<i data-lucide="arrow-left">` (Lucide icon, not chevron)
     - `.js-menu-carousel-next` with `<i data-lucide="arrow-right">` (Lucide icon, not chevron)
3. Button styling classes: `flex w-8 h-8 justify-center items-center cursor-pointer` (matching home carousel)
4. Icon classes: `w-5 h-5 text-secondary` (matching home carousel)
5. Keep all `js-menu-carousel-*` selector names unchanged to maintain binding contract

**Why:** The current arrows are inside the swiper root and absolutely positioned as dark overlays. The home carousel pattern places controls in a bar below the carousel. Template restructuring is required to achieve this layout.

**Constrained by:** A14 (Lucide icons for arrows), R3 (preserve js-* selector names), A10 (template organization)

### 2.4 Styling

**What will be modified:**
- `__src/css/app.css` — menu carousel section (currently lines ~359-422)

**Changes:**
1. **Remove** the absolute positioning styles for `.js-menu-carousel-prev` and `.js-menu-carousel-next` (the dark circular overlay styles: `position: absolute`, `top: 50%`, `transform`, `border-radius: 9999px`, `background: rgba(0,0,0,0.4)`, `color: rgba(255,255,255,0.9)`)
2. **Remove** the `.swiper-button-disabled` opacity/pointer-events rules for the arrow buttons (since Swiper will no longer manage these buttons, disabled state will be handled via JS directly)
3. **Remove** the `.swiper-pagination-bullet` and `.swiper-pagination-bullet-active` styles (Swiper built-in bullets are no longer used)
4. **Update** `.js-menu-carousel-pagination` styles: change from centered bullet layout to left-aligned seed layout (`display: flex`, `align-items: center`, `gap: 8px`, remove `justify-content: center`, remove `padding`)
5. **Add** seed-specific styling if needed (cursor pointer on seed spans — may be handled inline via Tailwind classes in JS-generated markup)
6. **Keep** the `.js-menu-carousel` base styles (position relative, overflow hidden) as they are still needed for the swiper container

**Why:** Current CSS is designed for the old visual pattern (overlay arrows, bullet pagination). All of it must be replaced to match the home carousel controls pattern.

**Constrained by:** R4 (CSS targets js-* selectors — updating styles for same selectors), A8/F4 (no hardcoded theme-dependent colors in new styles), S3 (state mechanisms)

### 2.5 Assets

No changes. No new images, fonts, or static assets. The seed SVG is generated inline in JS (same as product-carousel.js).

---

## 3. Execution Phases

### Phase 1: Template Restructure
- Modify `snipplets/navigation/menu-carousel.tpl` to move controls outside the swiper root into a controls bar
- Change arrow icons from `chevron-left`/`chevron-right` to `arrow-left`/`arrow-right`
- Apply Tailwind utility classes matching the home carousel controls layout
- **Testable by:** Visually inspecting the template renders correct HTML structure (controls bar below carousel). Carousel will be non-functional at this point (Swiper config still references old positions).

### Phase 2: JS Logic Update
- Modify `initMenuCarousel()` in `menu.js`:
  - Remove `navigation` and `pagination` from Swiper config
  - Add seed pagination rendering function with CSS variable-based colors
  - Add `slideChange` callback to re-render seeds
  - Add manual arrow click listeners
  - Add arrow disabled-state logic (beginning/end detection)
  - Ensure `lucide.createIcons()` is called after init for new Lucide arrow markup
- **Testable by:** Opening menu (desktop and mobile), verifying carousel slides, seed pagination updates on slide change, arrow clicks navigate slides, arrows dim at boundaries.

### Phase 3: CSS Cleanup & Refinement
- Remove old overlay arrow styles from `app.css`
- Remove bullet pagination styles from `app.css`
- Update/simplify pagination container styles
- Verify visual consistency between desktop dropdown and mobile menu contexts
- **Testable by:** Visual inspection in both desktop and mobile viewports. Seeds should use theme colors. Arrows should match home carousel style. No remnant dark overlay or bullet styles.

---

## 4. Risk Controls

### Edge Cases
- **Zero slides**: If no category images are configured in settings, the carousel template should not render (this is already handled by the existing `{% if categories %}` guard in the template). Seed pagination and arrows must not render for empty carousels.
- **Single slide**: If only one category exists, the swiper should show no pagination seeds and no arrows (or hide the controls bar entirely). Check `swiper.isLocked` or `slides.length <= 1`.
- **All slides visible**: With `slidesPerView: "auto"`, if all slides fit in the viewport without scrolling, pagination and arrows should be hidden. Use Swiper's `watchOverflow` behavior or check `swiper.isBeginning && swiper.isEnd` after init.
- **Re-initialization guard**: The `_swiperInit` flag prevents double init. However, seed rendering and arrow binding must only happen once per carousel instance. Verify the guard still works correctly after changes.
- **Desktop vs mobile width**: The carousel renders in both contexts at different widths. Seed count and arrow visibility must be correct in both. The `slidesPerView: "auto"` mode handles this, but verify visually.

### Regression Zones
- **Mobile menu open/close**: The `openMobileMenu` function triggers `requestAnimationFrame(initMenuCarousel)`. Verify that opening/closing the menu repeatedly does not duplicate event listeners or break seeds.
- **Desktop dropdown open/close**: The `openDesktopMenu` function also triggers carousel init. Same concern as mobile — verify no listener duplication.
- **Menu accordion/tab system**: The mobile menu has tabs (categories, pages, info) and accordions. The carousel lives inside one of these panels. Verify that tab switching does not affect carousel state.
- **Lucide icon rendering**: The new arrow markup uses Lucide icons. `lucide.createIcons()` must be called after the carousel template is visible in the DOM (it is called after Swiper init, which happens after menu open — this should be correct).

### Strict Non-Modification Areas
- **Swiper `slidesPerView: "auto"` and `spaceBetween: 0` config** — MUST NOT change
- **Swiper lazy init pattern** (`_swiperInit` guard + `requestAnimationFrame`) — MUST NOT change
- **Menu open/close logic** (`openMobileMenu`, `closeMobileMenu`, `openDesktopMenu`, `closeDesktopMenu`) — MUST NOT change
- **Menu accordion system** — MUST NOT change
- **Menu tab panel system** — MUST NOT change
- **Slide content** (category image cards inside `.swiper-slide`) — MUST NOT change
- **`product-carousel.js`** — MUST NOT modify (even though it has the A8 bug; fixing that is out of scope)
- **`home-product-carousel.tpl`** — MUST NOT modify
- **Any file outside the three listed in the Likely Impacted Areas** — MUST NOT modify
