# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A10, A14, D1, S2, S3, L5, R1, R3, F2, F4, F5, F6

### Invariant Tension Check

**A9 vs modal.js current design**: The gaius modal system (`modal.js`) currently only supports centered modals. The feature requires a drawer/sheet on mobile. Extending `modal.js` to support a `mode: "drawer"` option is architecturally safe — it adds a presentation variant to the same overlay system without violating A9 (both modes use `data-state="open"/"closed"`). No invariant conflict.

**A5 / S2 — Cross-module communication**: The new category filter module will call `window.openModal()` / `window.closeModal()` to trigger the modal/drawer. This is the mandated pattern. No horizontal imports needed.

**Legacy handler compatibility**: The jQuery delegation in `store.js.tpl` for `.js-apply-filter`, `.js-remove-filter`, `.js-remove-all-filters` uses jQuery event delegation on `document` or a parent container. Since the filter content will be rendered server-side within the new gaius modal container (via template includes), and jQuery delegation bubbles from any DOM position, the handlers will continue to fire. The `data-filter-name` and `data-filter-value` attributes will be preserved. No invariant tension.

**A8 / F4 — Hardcoded colors**: The reference design image contains hardcoded Tailwind colors (`text-red-950`, `bg-black`, etc.). These MUST be translated to theme tokens (`text-secondary`, `bg-bg-subtle`, `color-mix(...)` patterns). No tension — constraint applies cleanly.

### Risk Level
**MEDIUM**

Rationale: Extending `modal.js` with drawer mode introduces new CSS surface and JS logic. The critical risk is ensuring jQuery filter handlers continue to work after DOM relocation. Mitigated by using server-side template rendering (not dynamic JS innerHTML) for filter content.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

**No changes required.** Filter data continues to flow through Nuvemshop platform template variables (`{{ product_filters }}`, `{{ filter_categories }}`). Filter application logic stays in `store.js.tpl` via `LS.urlAddParam` / `LS.urlRemoveParam`. **(D1, L5)**

### 2.2 State / Hooks

**Modify: `__src/js/modules/system/modal.js`**
- Extend `openModal()` to accept a new `mode` option: `"modal"` (default, current behavior) or `"drawer"`.
- When `mode: "drawer"`, the generated `.js-gaius-modal-content` element receives an additional CSS class `js-gaius-modal-drawer` instead of centered max-width styling.
- Drawer mode applies `width: 100%; max-width: 100%; height: 100%; border-radius: 0;` via the class, positioned to the right side.
- The `data-state` attribute mechanism remains unchanged — `"open"` and `"closed"` drive visibility for both modes. **(A9, S3)**
- Add a new `content` option type: when `contentSelector` is provided instead of `content`, the modal reads innerHTML from a hidden DOM element (the template-rendered filter snipplet). This avoids JS-generated filter HTML and preserves platform template rendering + jQuery handler binding. **(D1, L5)**
- After opening with `contentSelector`, call `lucide.createIcons()` if any Lucide markup exists in the moved content. **(A6)**
- The module continues to expose `window.openModal` and `window.closeModal`. No new globals needed. **(A5, S2)**

**Create: `__src/js/modules/category/category-filters.js`**
- Named export: `export const categoryFilters = () => { ... }` **(A3, F6)**
- DOM guard: first statement checks for `.js-category-filter-trigger`; returns if not found. **(A2)**
- On click of `.js-category-filter-trigger`, calls `window.openModal()` with:
  - `title`: "Filtros" (read from a `data-filter-title` attribute on the trigger for i18n)
  - `contentSelector`: `.js-category-filter-content` (the hidden template-rendered filter panel)
  - `mode`: `"drawer"` on viewports < 768px, `"modal"` (size `"lg"`) on desktop
  - Viewport detection via `window.matchMedia("(max-width: 767px)")` at click time
- No horizontal module imports. **(R1, F2)**

**Modify: `__src/js/index.js`**
- Add import: `import { categoryFilters } from "./modules/category/category-filters";`
- Add invocation: `categoryFilters();`
- Follows existing named export pattern. **(A3)**

### 2.3 UI / Components

**Modify: `templates/category.tpl`**
- **Remove**: The `{% embed "snipplets/modal.tpl" ... %}` block (lines 121-139) — legacy modal container for filters.
- **Replace**: The filter trigger `<a>` tag (line 98) — change from `js-modal-open` class with `data-toggle="#nav-filters"` to a new `<button>` with class `js-category-filter-trigger`. Add `data-filter-title="{{ 'Filtros' | translate }}"` for i18n. **(R3 — new binding contract)**
- **Add**: A hidden `<div>` with class `js-category-filter-content` containing the filter snipplet includes (`grid/categories.tpl`, `grid/filters.tpl`) and the overlay elements. This hidden div serves as the content source for `window.openModal({ contentSelector })`. Uses `hidden` attribute per S3. **(A10, S3, R3)**
- **Preserve**: Applied filter chips block (lines 104-119) — no changes. **(Research A4)**
- **Preserve**: All `js-apply-filter`, `js-remove-filter`, `js-remove-all-filters` classes and `data-filter-name`/`data-filter-value` attributes on elements inside `grid/filters.tpl`. **(R3)**

**Modify: `snipplets/grid/filters.tpl`**
- Redesign the filter UI from checkbox-list style to pill/chip toggle style to match the reference image.
- Sort options become inline pill chips (rounded buttons) instead of checkboxes.
- Color filters show color dot swatches within pill chips.
- Size filters become pill chips.
- Price range filter retains its platform `{{ component('price-filter', ...) }}` call with updated wrapper classes.
- All `js-apply-filter` / `js-remove-filter` classes, `data-filter-name`, `data-filter-value` attributes MUST be preserved on the interactive elements. **(R3)**
- Replace SVG snipplet include (`snipplets/svg/times.tpl` on line 16) with Lucide `<i data-lucide="x">`. **(A14, F5)**
- All colors use theme tokens — selected state uses `bg-secondary text-bg` (inverted), unselected uses `[background:rgba(0,0,0,0.05)] text-secondary`. **(A8, F4)**

**Modify: `snipplets/grid/categories.tpl`**
- Update styling to match the pill/chip aesthetic of the new filter panel.
- Category links remain as `<a>` tags (navigation-based, not checkbox-based).
- Colors use theme tokens only. **(A8, F4)**

**No changes to**: `snipplets/notification/modal.tpl` (gaius modal container mount point remains as-is).

### 2.4 Styling

**Modify: `__src/css/app.css`**
- Add drawer mode styles for the gaius modal system:
  - `.js-gaius-modal-drawer` — full height, right-aligned, no border-radius, width 100% on mobile.
  - Desktop media query (`min-width: 768px`): `.js-gaius-modal-drawer` gets `max-width: 420px;` and slides from right.
  - Transition for drawer: `transform: translateX(100%)` when `data-state="closed"`, `transform: translateX(0)` when `data-state="open"` (overrides the default `scale(0.95)` modal transition).
- All colors use `var(--primary-color)`, `var(--background-color)`, `color-mix(...)`, or `@theme` token classes. **(A8, F4)**
- The container `.js-gaius-modal-container` styles remain unchanged — both modal and drawer share the fixed overlay container.

### 2.5 Assets

**No new assets required.** Icons use Lucide (already loaded): `sliders-horizontal` (filter trigger), `x` (close/remove), `chevron-down` (accordion). **(A14, F5, L4)**

---

## 3. Execution Phases

### Phase 1: Modal System Drawer Extension
1. Modify `__src/js/modules/system/modal.js` to support `mode: "drawer"` and `contentSelector` options.
2. Add drawer CSS styles to `__src/css/app.css` (drawer positioning, transitions, responsive breakpoints).
3. **Testable**: Open browser console, call `window.openModal({ title: "Test", content: "<p>Hello</p>", mode: "drawer" })` — verify drawer slides in from right, closes on overlay click, closes on Escape key.

### Phase 2: Template & Filter UI Restructure
1. Modify `templates/category.tpl`: remove legacy modal embed, add `js-category-filter-trigger` button, add hidden `js-category-filter-content` container with filter snipplet includes.
2. Modify `snipplets/grid/filters.tpl`: redesign from checkboxes to pill chips, preserve all `js-apply-filter`/`js-remove-filter` classes and data attributes, replace SVG with Lucide.
3. Modify `snipplets/grid/categories.tpl`: update styling to pill aesthetic.
4. **Testable**: Load category page — verify filter trigger button renders, hidden content div exists in DOM, legacy modal is gone, applied filter chips still display correctly.

### Phase 3: Category Filters JS Module
1. Create `__src/js/modules/category/category-filters.js` with the `categoryFilters` named export.
2. Modify `__src/js/index.js` to import and invoke `categoryFilters`.
3. **Testable**: Click filter button on desktop — modal opens with filter content. Click on mobile — drawer opens. Apply a filter — page reloads with filter applied. Remove a filter chip — filter removed. Close modal/drawer — content returns to hidden container. Verify all filter types work (sort, size, color, price).

---

## 4. Risk Controls

### Edge Cases
- **Empty filter state**: When `product_filters` is empty but `filter_categories` exists (or vice versa), the modal/drawer should still render correctly with only the available section.
- **Many filter values (>8)**: The accordion toggle (`js-accordion-container`, `js-accordion-toggle`) must work inside the modal/drawer context. These are jQuery-driven in `store.js.tpl` — verify delegation works.
- **Rapid open/close**: Ensure the `transitionend` cleanup in `modal.js` doesn't race with a re-open. The existing `setTimeout(cleanup, 400)` fallback handles this.
- **Viewport resize while open**: If user rotates device from mobile (drawer) to desktop (would expect modal), the drawer should remain functional — no live mode switch needed. Mode is determined at open time.
- **Filters overlay**: The `.js-filters-overlay` loading state shown during filter application must work inside the modal/drawer container.

### Regression Zones
- **Filter application flow**: The `js-apply-filter` → `LS.urlAddParam` → page reload chain MUST continue working. This is the highest regression risk. Test: click a filter checkbox/pill, verify URL changes and page reloads with filter applied.
- **Filter removal flow**: Both individual `js-remove-filter` chips and `js-remove-all-filters` link must work.
- **Price filter component**: The `{{ component('price-filter', ...) }}` platform component must render and function inside the new container.
- **Category dropdown** (`js-category-dropdown`): Unrelated to filter panel but shares the category header bar — verify it still works after layout changes.
- **Existing gaius modal callers**: Any other code calling `window.openModal()` without `mode` must continue to get centered modal behavior (default mode).

### Strict Non-Modification Areas
- `static/js/store.js.tpl` — Legacy filter handlers must NOT be modified.
- `snipplets/notification/modal.tpl` — Gaius modal mount point must NOT change.
- `__src/js/modules/category/category-dropdown.js` — Unrelated module, must NOT be touched.
- `__src/js/modules/category/category-infinite-scroll.js` — Unrelated module, must NOT be touched.
- Applied filter chips in `category.tpl` (lines 104-119) — Must NOT change structure or classes.
- `config/settings.txt` — No new settings needed for this feature.
- `__src/js/modules/system/header.js`, `menu.js`, `search.js` — Unrelated system modules, must NOT be touched.
