# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants

A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S3, L5, R1, R3, F2, F4, F5, F6

### Invariant Tension Check

**No tensions detected.** All invariants are compatible with the planned approach:

- **A9 vs S3**: The sorting dropdown is a binary open/close toggle (not a multi-state overlay). Per S3, `hidden` attribute + `aria-expanded` is the preferred mechanism for binary toggles. This matches the existing `category-dropdown.js` pattern. No `data-state` needed — A9 only applies to full-page overlays or multi-state components.
- **D1 vs LS integration**: The sorting will use direct URL navigation (`window.location` with `sort_by` query param) from custom JS. This does NOT call `LS.*` — it navigates to a new page URL with a query parameter, which the Nuvemshop server processes. Additionally, a hidden `<select class="js-sort-by">` will be rendered in the template as a fallback — the platform's `assorted-js` component may bind to it automatically. Both paths comply with D1.
- **A12**: The hidden `<select class="js-sort-by">` must be template-rendered (not dynamically created by JS) so that platform bindings can attach during their load phase. The custom JS module handles only the visual dropdown interaction and URL navigation.

### Risk Level

**LOW**

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

**No new data services required.**

The Nuvemshop platform provides all necessary data via template variables already available in the category context:
- `sort_methods` — array of available sort keys (e.g., `['price-ascending', 'price-descending', 'alpha-ascending', ...]`)
- `sort_by` — currently active sort key (from URL query string)
- `category.sort_method` — the category's admin-defined default sort order

These are consumed directly in templates. No fetch, no AJAX, no LS.* calls.

### 2.2 State / Hooks

**New module: `category-sorting.js`** — stateless (state lives in DOM)

- **Root DOM guard**: `.js-category-sorting` (A2)
- **State mechanism**: `hidden` attribute on option list + `aria-expanded` on trigger (S3 — mechanisms 1 and 3)
- **Icon rotation**: `element.style.transform` for chevron rotation on open/close (S3 — mechanism 5, acceptable because it's a computed rotation value matching `category-dropdown.js` precedent)
- **Sort selection**: On option click, navigate via `window.location.href` to the current URL with `sort_by` query parameter updated. This is a full page navigation — no local state persistence needed.
- **No cross-module communication**: Module is self-contained. No new `window.*` globals (A5 unchanged).
- **No persistent state**: No localStorage/sessionStorage (S4 unchanged).

**Constrained by**: A1, A2, A3, S3, R1, F6

### 2.3 UI / Components

#### 2.3.1 Template: `templates/category.tpl` — MODIFY

Two insertion points for the sorting dropdown (matching the filter button's dual-breakpoint pattern):

**Desktop (inside title flex row, to the LEFT of filter button)**:
- Insert sorting dropdown markup BEFORE the existing `{% if has_filters_available %}` block (line 95) and AFTER the category dropdown block (line 93)
- Uses `hidden md:flex` to show only on desktop
- Container class: `.js-category-sorting`
- Trigger button with current sort label + Lucide chevron-down icon
- Absolute-positioned option list with sort methods, hidden by default
- Each option is a `<button>` with `data-sort-value` attribute
- Currently active sort option receives a visual indicator (e.g., `font-bold` or a Lucide `check` icon)

**Mobile (below breadcrumb, alongside mobile filter button)**:
- Insert sorting dropdown markup AFTER the breadcrumb include (line 104) and BEFORE the mobile filter button (line 106)
- Uses `flex md:hidden` to show only on mobile
- Same structure as desktop but separate DOM instance (follows the dual-button pattern established by filter triggers)
- Both instances share the same `js-*` class contract — the JS module uses `querySelectorAll` to handle multiple instances

**Hidden native select** (for platform compatibility):
- Render a hidden `<select class="js-sort-by">` with all `sort_methods` options, positioned visually hidden (`hidden` attribute or `sr-only` class)
- This ensures the Nuvemshop platform's `assorted-js` component can bind to it as a fallback
- Template-rendered, not JS-created (A12 compliance)

**Sort method label mapping** (within the template via `{% set %}`):
- Define a `sort_text` map matching sort keys to translatable labels
- Use `| translate` or `| t` filter on each label for i18n
- Labels: `best-selling` → "Mais vendidos", `price-ascending` → "Menor preço", `price-descending` → "Maior preço", `alpha-ascending` → "A - Z", `alpha-descending` → "Z - A", `created-descending` → "Mais novo"
- Conditionally show `user` option only if `category.sort_method == 'user'` (matching `sort-by.tpl` logic)

**Constrained by**: A8 (colors via Tailwind tokens), A10 (template includes by domain), A14 (Lucide icons), F4 (no hardcoded colors), F5 (no SVG snipplets)

#### 2.3.2 Snipplet: `snipplets/grid/sort-by.tpl` — NO MODIFICATION

The existing `sort-by.tpl` uses `{% embed "snipplets/forms/form-select.tpl" %}` which renders a native `<select>` with platform-bound styling (`form-select`, `form-group`). This does not match the custom dropdown visual pattern of the category page. Instead of modifying or including this snipplet, the sorting dropdown HTML will be written directly in `category.tpl` following the same inline pattern used by the category dropdown (lines 63-92 of `category.tpl`). The `sort-by.tpl` snipplet remains untouched as it may be used by other page templates (e.g., search results) in the future.

#### 2.3.3 JS Module: `__src/js/modules/category/category-sorting.js` — CREATE

New module file following the exact pattern of `category-dropdown.js`:

- Named export: `categorySorting`
- Root guard: `document.querySelectorAll(".js-category-sorting")` — returns early if none found
- For each sorting dropdown instance: bind trigger click → toggle open/close, bind option click → navigate with sort_by param, bind document click → close on outside click
- URL construction: read current URL, update/add `sort_by` query parameter, navigate via `window.location.href`
- No `lucide.createIcons()` needed — icons are template-rendered, not dynamically injected (A6 not triggered)

**New `js-*` class contracts (R3)**:
- `.js-category-sorting` — root container (guard element)
- `.js-category-sorting-trigger` — trigger button
- `.js-category-sorting-list` — option list (toggled via `hidden`)
- `.js-category-sorting-icon` — chevron icon (rotated via `style.transform`)
- `.js-category-sorting-option` — individual sort option buttons (with `data-sort-value`)

**Constrained by**: A1, A2, A3, F2, F6, L5, R1, R3

#### 2.3.4 Entry Point: `__src/js/index.js` — MODIFY

Add import and invocation under the `//Category` comment group:
- Import `categorySorting` from `./modules/category/category-sorting`
- Call `categorySorting()` after existing category module invocations
- This brings the category import count from 3 to 4

**Constrained by**: A3

### 2.4 Styling

**Minimal CSS required.** The sorting dropdown will use Tailwind utility classes directly in the template, matching the existing category dropdown's styling approach (lines 63-92 of `category.tpl`). Specifically:

- Trigger button: `[background:rgba(0,0,0,0.05)]` (permitted — rgba(0,0,0,*) overlay per A8), `text-secondary`, `rounded-lg`, `text-sm`, `font-medium`
- Option list: `bg-bg/70 backdrop-blur-sm` (uses Tailwind theme token `bg` for background, NOT the hardcoded `rgba(255,255,246,0.7)` which is a known bug in the existing category dropdown), `rounded-lg`, `shadow-md`, `absolute`, `z-20`
- Active option indicator: `font-bold` or Lucide `check` icon alongside the label
- Hover state: `hover:bg-black/5` (permitted overlay)

**Important**: The existing category dropdown at `category.tpl:78` uses `[background:rgba(255,255,246,0.7)]` which is a KNOWN BUG (A8, item 5). The sorting dropdown MUST NOT replicate this bug. It must use `bg-bg/70 backdrop-blur-sm` or `[background:color-mix(in_srgb,var(--background-color)_70%,transparent)]` instead.

**No `app.css` modifications expected** unless transition animations are desired for the dropdown panel. If transitions are added, they must use `data-state` per A9 — but given the existing `category-dropdown.js` uses no CSS transitions (just `hidden` toggle), the sorting dropdown should follow the same simple pattern.

**Constrained by**: A8, F4

### 2.5 Assets

**No new assets required.**

- Icons: Lucide `chevron-down` (already in use) and optionally `check` (for active sort indicator) — both exist in Lucide library (A14)
- No images, fonts, or external resources needed

---

## 3. Execution Phases

### Phase 1: Template Markup

**Goal**: Render the sorting dropdown HTML in `category.tpl` with correct responsive positioning and translatable labels. Page should display the dropdown visually but without JS interaction.

**Tasks**:
1. Add `{% set sort_text %}` map at the top of `category.tpl` (after existing `{% set %}` blocks) mapping sort keys to translatable labels
2. Add desktop sorting dropdown markup inside the title flex row (between category dropdown and filter button), using `hidden md:flex` visibility
3. Add mobile sorting dropdown markup after breadcrumb and before mobile filter button, using `flex md:hidden` visibility
4. Add hidden `<select class="js-sort-by">` with all `sort_methods` for platform compatibility
5. Use `bg-bg/70 backdrop-blur-sm` for dropdown list background (NOT the buggy `rgba(255,255,246,0.7)`)
6. Use Lucide `<i data-lucide="chevron-down">` for the trigger icon (A14)
7. Mark currently active sort option using `sort_by` template variable comparison

**Testable**: Load category page in browser — dropdown markup renders correctly at both breakpoints, labels display in correct language, active sort is visually indicated, but dropdown does not open/close (no JS yet).

### Phase 2: JS Module

**Goal**: Create the `category-sorting.js` module that controls dropdown toggle behavior and sort navigation.

**Tasks**:
1. Create `__src/js/modules/category/category-sorting.js` with named export `categorySorting`
2. Implement root DOM guard: `querySelectorAll(".js-category-sorting")` — return if empty
3. For each instance: query trigger, list, icon, and option elements via scoped `js-*` selectors
4. Implement open/close/toggle functions using `hidden` attribute + `aria-expanded` + icon rotation (matching `category-dropdown.js` pattern exactly)
5. Implement option click handler: read `data-sort-value`, construct URL with `sort_by` query param, navigate via `window.location.href`
6. Implement outside-click close handler via `document.addEventListener("click", ...)`
7. Add import and invocation to `__src/js/index.js` under `//Category` group

**Testable**: Build JS bundle, load category page — dropdown opens/closes on click, closes on outside click, clicking a sort option navigates to the correct sorted URL, page reloads with products in new order, the dropdown reflects the new active sort.

### Phase 3: Polish & Validation

**Goal**: Validate all interactions, edge cases, and cross-feature compatibility.

**Tasks**:
1. Verify sorting works correctly with infinite scroll (the `pages.next` URL preserves `sort_by` param — should work without changes)
2. Verify sorting dropdown coexists with category dropdown (both can open independently, opening one does not affect the other)
3. Verify sorting dropdown coexists with filter button (filters + sorting can be used in combination)
4. Verify mobile layout: sorting dropdown and filter button render side-by-side or stacked neatly below breadcrumb
5. Verify the hidden `<select class="js-sort-by">` is in the DOM and has the correct selected value (platform fallback)
6. Verify no hardcoded theme-dependent colors were introduced (A8 compliance check)
7. Verify all icons are Lucide (A14 compliance check)

**Testable**: Full manual QA pass — sort by each option, combine with filters, scroll to trigger infinite scroll, test on mobile viewport.

---

## 4. Risk Controls

### Edge Cases

1. **No sort methods available**: If `sort_methods` is empty (unlikely but possible for unusual category configs), the entire sorting dropdown must be conditionally hidden. Wrap in `{% if sort_methods is not empty %}`.
2. **`user` sort method**: Only show "Destacado" option when `category.sort_method == 'user'` (admin chose manual ordering). This logic exists in `sort-by.tpl` and must be replicated.
3. **Current sort not in list**: If `sort_by` value doesn't match any known key, the trigger label should show a default text (e.g., "Ordenar" / "Ordenar por").
4. **URL parameter preservation**: When navigating to a sorted URL, all existing query parameters (especially filters like `?Color=Rojo`) must be preserved. The JS must update/add only the `sort_by` param, not replace the entire query string.
5. **Multiple dropdown instances**: Both desktop and mobile instances use the same `js-*` class selectors. The JS module must use `querySelectorAll` and iterate, not `querySelector` for a single instance. Outside-click handler must close all instances.
6. **Dropdown z-index stacking**: The sorting dropdown list uses `z-20`. Verify it doesn't conflict with the category dropdown list (also `z-20`). Since only one should be open at a time (user interaction), this is acceptable but should be visually verified.

### Regression Zones

1. **Category dropdown** (`category-dropdown.js`): Must remain fully functional. The sorting dropdown uses different `js-*` selectors (`js-category-sorting-*` vs `js-category-dropdown-*`) so there is zero selector collision. No modification to `category-dropdown.js`.
2. **Category filters** (`category-filters.js`): Must remain fully functional. Filter button positioning changes slightly (sorting dropdown is inserted before it in the flex row). Verify filter button still renders correctly at both breakpoints.
3. **Infinite scroll** (`category-infinite-scroll.js`): Must continue working when a sort is active. The `data-next-url` from `pages.next` should include the `sort_by` param automatically (platform behavior). No changes to this module.
4. **Layout flex row** (`category.tpl:49`): Adding a new element to the `flex items-center gap-3 mb-2` row. On small desktop viewports, verify the row doesn't overflow or wrap awkwardly with title + category dropdown + sorting dropdown + filter button.
5. **Existing hardcoded color bug** (`category.tpl:78`): The existing `rgba(255,255,246,0.7)` on the category dropdown list is a known bug (A8 item 5). This plan does NOT fix it — it only ensures the new sorting dropdown does not replicate it. Fixing the existing bug is out of scope.

### Strict Non-Modification Areas

- `__src/js/modules/category/category-dropdown.js` — no changes
- `__src/js/modules/category/category-filters.js` — no changes
- `__src/js/modules/category/category-infinite-scroll.js` — no changes
- `snipplets/grid/sort-by.tpl` — no changes (kept for potential future use elsewhere)
- `snipplets/forms/form-select.tpl` — no changes
- `static/js/store.js.tpl` — no changes (platform file)
- `static/css/app.tpl` — no changes (build output, F1)
- `static/js/gaius-v*.js` — no changes (build output, F1)
- `config/settings.txt` — no changes (no new admin settings needed for this feature)
- `layouts/layout.tpl` — no changes
