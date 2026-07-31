# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A6, A8, A9, A10, A13, A14, D1, S3, L5, R1, R3, F4, F5, F6

### Invariant Tension Check
- **A9 vs header-new.tpl**: The header currently hardcodes `data-state="transparent"`. The feature requires `data-state="active"` on non-home pages. This is NOT a violation — A9 defines the pattern, and the change merely adjusts the initial template value via a conditional. The JS in `header.js` will continue to manage state transitions normally.
- **A1 (new context directory)**: Creating `__src/js/modules/category/` is explicitly permitted by A1's extension rule ("New contexts MUST be created as new subdirectories under `modules/`").
- **item-card.tpl vs item.tpl**: The research identifies that `item-card.tpl` (Tailwind) lacks quickshop, installments, and variant features present in `item.tpl` (Bootstrap). For this phase, the category grid will continue using `item.tpl` via `product_grid.tpl` (existing pattern) to preserve full product card functionality. A future dedicated task can migrate `item.tpl` to Tailwind. This avoids scope expansion.
- **No invariant violations detected.**

### Risk Level
**MEDIUM**
- Header `data-state` initial value change affects all non-home pages globally (product, cart, search, account, etc.) — must be visually validated across all page types.
- Full `category.tpl` rewrite from Bootstrap to Tailwind changes the entire category page structure.
- No test infrastructure means all validation is manual.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
**No changes required.** All data is already provided by the Nuvemshop platform via template variables (`category.name`, `category.url`, `filter_categories`, `products`, `pages.*`, `breadcrumbs`). No new data sources, AJAX calls, or services needed. (Constrained by D1 — JS reads from DOM only.)

### 2.2 State / Hooks

**New file: `__src/js/modules/category/category-dropdown.js`**
- Purpose: Handle the subcategory dropdown open/close behavior and chevron icon rotation on the category header bar.
- Why: The dropdown is server-rendered with `<a>` links for navigation, but the open/close toggle requires JS. This follows the same interaction pattern as the product carousel dropdown (`product-carousel.js`) but must NOT import from it (R1, F9).
- Constrained by: A1 (new `category/` directory), A2 (DOM guard), A3 (named export), L5 (vanilla JS), F6 (no self-execution), S3 (prefer `hidden` attribute for show/hide).
- Exports: `categoryDropdown` (named export).
- DOM guard: Check for `.js-category-dropdown` existence as first statement (A2).
- State mechanism: Use `hidden` attribute to toggle dropdown list visibility (S3 preference #1). Use `aria-expanded` on the trigger button (S3 preference #3).

**Modified file: `__src/js/index.js`**
- Add import: `import { categoryDropdown } from "./modules/category/category-dropdown";`
- Add invocation: `categoryDropdown();`
- Constrained by: A3 (named import + explicit call).

### 2.3 UI / Components

**Modified file: `templates/category.tpl`** (Full rewrite)
- Replace Bootstrap grid (`container`, `row`, `col-*`) with Tailwind layout.
- Structure:
  1. **Category header bar**: `flex` container with category name (`<h1>`), subcategory dropdown (if `filter_categories` is not empty), and "Filtros" link button (non-functional placeholder).
  2. **Breadcrumb**: Inline or snipplet-based Tailwind breadcrumb using `breadcrumbs` template variable.
  3. **Product grid**: Responsive CSS grid — `grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4` wrapping the existing `product_grid.tpl` include.
  4. **Pagination**: Continue including `snipplets/grid/pagination.tpl` with `{ infinite_scroll: true }`.
  5. **Empty state**: Retain the "no results" message when no products exist.
- The subcategory dropdown renders `filter_categories` as `<a>` links (full page navigation), with a "Todos" link pointing to the current category URL.
- All `js-*` classes for the dropdown become binding contracts (R3): `.js-category-dropdown`, `.js-category-dropdown-trigger`, `.js-category-dropdown-list`, `.js-category-dropdown-icon`.
- Icons: Lucide for dropdown chevron (`<i data-lucide="chevron-down">`), filter icon (`<i data-lucide="sliders-horizontal">`), breadcrumb separator (`/` as text character, not icon). Constrained by A14, F5.
- Colors: All from Tailwind tokens (`text-fg`, `text-secondary`, `bg-bg`, etc.). Constrained by A8, F4.
- The existing filter modal (Bootstrap `modal.tpl`) and sort-by component will be removed from the new template since filter panel is out of scope. Only the "Filtros" clickable text/button remains as a placeholder.
- Why: Current layout uses Bootstrap classes incompatible with the Tailwind design system. The Figma specifies a completely different visual structure.

**New file: `snipplets/navigation/breadcrumb-category.tpl`**
- Purpose: Tailwind-styled breadcrumb for the category page.
- Receives category breadcrumb data from the `breadcrumbs` template variable (already available in Nuvemshop category pages).
- Renders: "Início / Category / Subcategory" with `/` as text separators, small text, left-aligned.
- Constrained by: A10 (organized in `snipplets/navigation/` domain folder), A14 (no SVG snipplets for separators).
- Why: The existing `snipplets/breadcrumbs.tpl` is Bootstrap-based and tightly coupled to legacy styling. A new Tailwind breadcrumb is needed for the new design. Placed in `navigation/` which is an existing domain folder.

**Modified file: `snipplets/header/header-new.tpl`** (Minimal change)
- Change: Replace `data-state="transparent"` with a template conditional:
  `data-state="{% if template == 'home' %}transparent{% else %}active{% endif %}"`
- Why: On non-home pages (category, product, cart, etc.), the header must start in the colored/active state because there is no hero banner behind it. Currently, the transparent state makes header text invisible on white backgrounds.
- Constrained by: A9 (uses existing `data-state` pattern).
- Impact: This affects ALL non-home pages globally. The `header.js` scroll logic will still transition to `active` on scroll, but the initial state will already be `active`, so the scroll threshold check (`scrollY > SCROLL_THRESHOLD`) will effectively be a no-op on non-home pages (it would set `active` again). This is correct behavior.

**Modified file: `snipplets/product_grid.tpl`** (Minimal change)
- The existing file includes `snipplets/grid/item.tpl` for each product. This will be wrapped in a CSS grid container applied from `category.tpl` (the grid classes go on the wrapper `div` in `category.tpl`, not inside `product_grid.tpl`).
- The `item.tpl` currently uses Bootstrap `col-*` classes for sizing. Inside a CSS grid parent, these `col-*` classes will need to be neutralized. This will be handled by passing a context variable (e.g., `{% set grid_mode = 'tailwind' %}`) that `item.tpl` can check, OR by overriding item width via the CSS grid parent (`grid` parent ignores `col-*` float widths).
- Decision: Use CSS grid on the parent container. Grid children automatically fill grid cells regardless of their own width classes. The Bootstrap `col-*` classes on `item.tpl` set `flex` and `max-width` which CSS Grid overrides. No modification to `item.tpl` needed — the grid parent controls sizing.
- Why: Avoids modifying the legacy `item.tpl` which is shared across category, search, and other pages.

**Modified file: `snipplets/grid/pagination.tpl`** (Potential minimal restyling)
- The pagination includes Bootstrap classes (`btn btn-primary`, `d-flex`, etc.) and SVG snipplet includes. For this phase, keep the existing pagination as-is since it's functionally correct (infinite scroll with "load more" button). The styling gap (Bootstrap classes in a Tailwind page) is acceptable as a known debt — the pagination is managed by Nuvemshop's JS (`store.js.tpl`) and modifying it risks breaking the infinite scroll integration.
- No modification in this phase.

### 2.4 Styling

**Modified file: `__src/css/app.css`** (Minimal additions)
- The category dropdown may need a small amount of custom CSS if Tailwind utilities cannot express the open/close animation. Based on existing patterns:
  - The dropdown toggle can be handled entirely via `hidden` attribute + Tailwind classes — no custom CSS needed.
  - The `data-state="active"` header background color already uses `rgba(255, 255, 246, 0.7)` (line 90) — this is a KNOWN BUG (A8) but is NOT in scope to fix here. The header will work correctly with the existing active state styling.
- No new CSS additions expected. All styling via Tailwind utility classes in templates.

### 2.5 Assets
**No new assets required.** All icons use Lucide (already loaded). No new images, fonts, or vendored libraries.

---

## 3. Execution Phases

### Phase 1: Header State Fix (Foundation)
1. Modify `snipplets/header/header-new.tpl` — change `data-state="transparent"` to conditional `data-state="{% if template == 'home' %}transparent{% else %}active{% endif %}"`.
2. Verify `header.js` behavior: confirm that `updateHeaderState()` called on page load with `handleScroll()` will correctly maintain `active` state on non-home pages (scrollY=0, no menu active → would set `transparent`, but the template now starts as `active`). **IMPORTANT**: The JS currently overrides `data-state` on load via `handleScroll()`. At `scrollY=0` and `isMenuActive=false`, it sets `transparent`. This will CONFLICT with the template conditional. The fix must also update `header.js` to detect non-home pages and preserve `active` state. Two approaches:
   - (a) Add a `data-initial-state` attribute to the header in the template, and have `header.js` read it to know the floor state.
   - (b) Check `document.body` or a class/data attribute that identifies the page type.
   - Approach (a) is preferred because it keeps the logic in the template (source of truth for initial state) and the JS reads from DOM (D1 compliant).
   - Template: add `data-initial-state="{% if template == 'home' %}transparent{% else %}active{% endif %}"` to the header element.
   - JS: read `header.dataset.initialState` and use it as the fallback instead of hardcoded `"transparent"`.
3. Test: Verify header appears colored on category page load, transparent on home page load, and transitions correctly on scroll for both.

### Phase 2: Category Page Template + Breadcrumb
1. Create `snipplets/navigation/breadcrumb-category.tpl` — Tailwind breadcrumb component.
2. Rewrite `templates/category.tpl` — full replacement with Tailwind layout:
   - Category header bar (name, dropdown markup, filter placeholder).
   - Breadcrumb include.
   - Product grid wrapper with CSS grid classes around existing `product_grid.tpl` include.
   - Pagination include (unchanged).
   - Empty state.
3. Test: Verify category page renders with correct layout, breadcrumb displays, product grid shows 2/3/4 columns at breakpoints, pagination works.

### Phase 3: Category Dropdown JS Module
1. Create `__src/js/modules/category/category-dropdown.js` — dropdown toggle logic.
2. Modify `__src/js/index.js` — add import and invocation.
3. Build JS bundle (`npm run build:js` or watch mode).
4. Test: Verify dropdown opens/closes on click, chevron rotates, links navigate to child categories, dropdown is hidden by default.

---

## 4. Risk Controls

### Edge Cases
- **Category with no subcategories**: The dropdown trigger must be hidden entirely when `filter_categories` is empty. Template conditional handles this.
- **Category with no products**: The "no results" empty state must display correctly without the grid or pagination.
- **Deep nested category**: When navigating to a grandchild category, `filter_categories` should provide that level's children. Verify this is Nuvemshop's behavior.
- **Header state on page with scroll restoration**: Browser back-navigation may restore scroll position. `header.js`'s `handleScroll()` fires on load and will correctly set `active` if scrolled, but the `initialState` logic must not override this.
- **Header state during menu interaction**: `window.setHeaderMenuActive(true)` must still force `active` state regardless of page type — the `initialState` is a floor, not a ceiling.
- **Product grid with fewer than 4 items**: CSS grid must not stretch items. Use `grid-cols-*` (not `auto-fill`) to maintain consistent column sizes.
- **Pagination infinite scroll**: The `js-load-more` and `js-infinite-scroll-spinner` elements are bound by `store.js.tpl`. The new template must preserve these exact class names and DOM structure for the legacy JS to function.

### Regression Zones
- **All non-home pages** (product, cart, search, account, blog): The header `data-state` change affects these globally. Must verify header appearance on each page type.
- **Home page hero banner**: The header must still start as `transparent` on home when hero banner is present. Verify no regression.
- **Search page**: Uses similar grid structure (`item.tpl`). Must not be affected by category template changes.
- **Product grid on category**: `product_grid.tpl` is shared between category, search, and potentially other pages. Changes to the grid wrapper in `category.tpl` must not affect other consumers.
- **Infinite scroll / load more**: The pagination JS in `store.js.tpl` depends on specific DOM selectors. The new template must preserve the container structure that `store.js.tpl` expects (specifically `js-product-table` class and `data-store` attribute).

### Strict Non-Modification Areas
- `snipplets/grid/item.tpl` — Legacy product card. Must not be modified.
- `snipplets/grid/item-card.tpl` — Tailwind product card. Out of scope for this feature.
- `store.js.tpl` — Legacy jQuery code. Must not be modified.
- `external.js.tpl` / `external-no-dependencies.js.tpl` — Vendored libraries.
- `config/settings.txt` — No new settings required for this feature.
- `snipplets/home/home-section-switch.tpl` — Home section router. Unrelated.
- `__src/js/modules/system/header.js` — Modification is limited ONLY to reading `data-initial-state` for the floor state. No structural changes.
- `__src/js/modules/home/*` — No modifications.
- `snipplets/grid/pagination.tpl` — Keep as-is to avoid breaking infinite scroll integration.
- `layouts/layout.tpl` — No modifications.
