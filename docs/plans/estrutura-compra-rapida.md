# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A10, A14, D1, S2, S3, L5, R1, R3, F4, F5, F6, F9

### Invariant Tension Check

**Tension: Infinite scroll `renderCard()` vs variation data (D1 + A6)**
The current `category-infinite-scroll.js` extracts product data from fetched HTML via `extractProducts()` and re-renders cards using a JS `renderCard()` function. This function does NOT extract variation data (variation names, options, IDs). Two viable resolutions:

- **Option A (Preferred)**: Change infinite scroll to extract and insert the raw server-rendered card HTML directly from the fetched page instead of decomposing and re-rendering. This preserves all template-rendered variation markup and `data-*` attributes without needing to replicate the variation template logic in JS. This modifies `category-infinite-scroll.js` but stays within scope since infinite scroll is a listed impacted area.
- **Option B**: Extend `extractProducts()` and `renderCard()` to handle variation data. This is fragile and duplicates template logic in JS — violates the spirit of D1 (JS reads from DOM, does not replicate template rendering).

**Resolution**: Option A — extract raw card HTML from fetched pages. This is architecturally cleaner and avoids duplicating template logic. The `extractProducts()` + `renderCard()` pattern will be replaced with direct HTML extraction from the fetched document's `.js-category-grid` children.

**No other invariant tensions found.** All invariants are compatible with the feature scope.

### Risk Level
**MEDIUM**

Rationale:
- Infinite scroll re-initialization requires event delegation or `window.*` re-init
- Multiple dropdown instances per page (N variations × M product cards) require scoped handling
- Mobile layout change affects card height in Swiper carousels
- Must avoid propagating known `rgba(255,255,246,0.7)` bug from existing dropdowns

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

No new data services. All variation data is already available in the template scope via `product.variations` (confirmed in `item.tpl`, `product-variants.tpl`). Each variation has:
- `variation.name` (e.g., "Size", "Color")
- `variation.id`
- `variation.options[]` — each with `option.id` and `option.name`

This data will be rendered into `data-*` attributes on the card HTML by the template (per D1).

### 2.2 State / Hooks

**New module: `__src/js/modules/system/item-card-quickbuy.js`**

- **What**: Named export `itemCardQuickbuy` that handles dropdown open/close toggling for variation selectors on item cards.
- **Why**: Item cards appear on home (grid + carousel) and category pages — must be in `system/` for global loading (A1). A dedicated module is needed because `category-dropdown.js` handles a single dropdown instance with `.querySelector()`, while this feature requires handling N dropdowns across M cards.
- **Constrained by**: A1 (system/ directory), A2 (DOM guard), A3 (named export), S3 (hidden attr + aria-expanded preferred), R1 (standalone, no horizontal imports), F6 (no self-execution).

**State management approach**:
- Use **event delegation** on `document` (or a shared ancestor) to handle click events on `.js-quickbuy-dropdown-trigger` elements. This eliminates the need for re-initialization after infinite scroll appends new cards.
- Dropdown state expressed via `hidden` attribute on the options list and `aria-expanded` on the trigger (S3 preference order: hidden > data-state > aria-expanded).
- Chevron rotation via `element.style.transform` (acceptable per S3 — it's a computed visual toggle, consistent with `category-dropdown.js` pattern).
- Close dropdown when clicking outside (document-level click listener, scoped check via `.closest()`).
- Only one dropdown open at a time across all cards — opening a new dropdown closes the previously open one.

**Cross-module communication**:
- Register `window.initQuickbuyDropdowns` as a no-op or optional re-init function for future use. Since event delegation handles dynamic cards automatically, this is a safety net only. Must be documented in A5/S2 registry.
- The "+" button is inert — no `window.*` signal needed yet. Future cart integration will add behavior via a new `window.*` global per A5/S2.

**Modified: `__src/js/index.js`**
- Add import `{ itemCardQuickbuy }` from `./modules/system/item-card-quickbuy` under `//System` group.
- Add invocation `itemCardQuickbuy();`
- Constrained by A3 (grouped imports, named export, explicit invocation).

### 2.3 UI / Components

**Modified: `snipplets/grid/item-card.tpl`**

Changes:
1. **Remove** the current shopping cart icon button (`<button>` with `<i data-lucide="shopping-cart">`).
2. **Add quick-buy container** inside the image container (for desktop: absolute positioned at bottom) AND below the image container (for mobile: relative flow position). Implementation will use a single HTML block with responsive Tailwind classes to handle the layout shift (e.g., `absolute bottom-0 md:absolute` on desktop, repositioned on mobile via responsive utilities).
3. **Variation dropdowns**: For each `product.variations`, render a dropdown structure:
   - Container with class `.js-quickbuy-dropdown` and `data-variation-id="{{ variation.id }}"`
   - Trigger button with class `.js-quickbuy-dropdown-trigger`, `aria-expanded="false"`, displaying `{{ variation.name }}`
   - Options list (hidden by default) with class `.js-quickbuy-dropdown-list`, containing one option element per `variation.options` with `data-option-id="{{ option.id }}"` and text `{{ option.name }}`
   - Chevron icon: `<i data-lucide="chevron-down" class="js-quickbuy-dropdown-icon">`
4. **"+" button**: `<button class="js-quickbuy-add-btn" aria-label="{{ 'Agregar al carrito' | translate }}"><i data-lucide="plus"></button>` — inert, no JS behavior.
5. **Conditional rendering**: Wrap dropdowns in `{% if product.variations %}`. The "+" button always renders.
6. **Styling approach**: Dropdown triggers use `[background:rgba(0,0,0,0.05)]` (permitted semi-transparent overlay per A8/F4), `backdrop-blur` via Tailwind, pill-shaped with rounded corners. Consistent with existing badge styling already in the card.

**New `js-*` class contracts** (R3):
- `.js-quickbuy-dropdown` — dropdown container per variation
- `.js-quickbuy-dropdown-trigger` — clickable trigger
- `.js-quickbuy-dropdown-list` — options list (hidden/shown)
- `.js-quickbuy-dropdown-icon` — chevron icon for rotation
- `.js-quickbuy-dropdown-option` — individual option element
- `.js-quickbuy-add-btn` — add-to-cart button (inert for now)
- `.js-quickbuy-container` — wrapper for all quick-buy elements

**Modified: `__src/js/modules/category/category-infinite-scroll.js`**

Changes:
1. **Replace** the `extractProducts()` + `renderCard()` pattern with direct HTML extraction from fetched pages. Instead of parsing product fields and re-building HTML, extract the raw card elements from the fetched document's `.js-category-grid` children and insert their `outerHTML` directly.
2. This ensures dynamically loaded cards include the full variation dropdown markup rendered by the server template.
3. `lucide.createIcons()` call after insertion remains (already exists at line 278-280).
4. Event delegation in `item-card-quickbuy.js` handles dropdown behavior automatically for new cards — no explicit re-initialization needed.
5. **Constrained by**: D1 (fetch permitted for pagination), A6 (lucide re-init after innerHTML).

### 2.4 Styling

**Possibly modified: `__src/css/app.css`**

Responsive layout for the quick-buy container:
- Desktop: dropdowns + button overlaid at bottom of image container, positioned `absolute`, with a semi-transparent background strip.
- Mobile: dropdowns + button placed below the image, in normal flow, increasing card height.

If Tailwind utility classes alone handle this (likely via responsive `absolute`/`relative` positioning, `flex`, `gap`, `hidden md:flex` patterns), no `app.css` changes are needed. If animations or state-driven styles for dropdown open/close are needed beyond what `hidden`/`aria-expanded` provides, minimal additions to `app.css` using the `.js-quickbuy-*[aria-expanded]` pattern (consistent with R4).

### 2.5 Assets

No new assets. Icons used: `plus` and `chevron-down` — both exist in the Lucide library (A14). No new SVG snipplets (F5).

---

## 3. Execution Phases

### Phase 1: Template Structure
- Modify `snipplets/grid/item-card.tpl` to add the quick-buy structure (variation dropdowns + "+" button)
- Remove the old shopping cart icon button
- Render variation data into `data-*` attributes and DOM structure
- Use Tailwind classes for responsive layout (desktop overlay vs mobile flow)
- Verify template renders correctly with static HTML (no JS behavior yet)

### Phase 2: JS Module + Entry Point
- Create `__src/js/modules/system/item-card-quickbuy.js` with event delegation for dropdown toggling
- DOM guard on `.js-quickbuy-dropdown` existence (A2)
- Named export `itemCardQuickbuy` (A3/F6)
- Open/close logic using `hidden` + `aria-expanded` (S3)
- Single-dropdown-open-at-a-time behavior
- Close on outside click
- Chevron rotation on toggle
- Register `window.initQuickbuyDropdowns` (optional, for future use)
- Modify `__src/js/index.js` — import and invoke under `//System`

### Phase 3: Infinite Scroll Adaptation
- Modify `category-infinite-scroll.js` to extract raw card HTML from fetched pages instead of decomposing/re-rendering
- Replace `extractProducts()` + `renderCard()` with direct `.js-category-grid [data-product-id]` outerHTML extraction
- Verify `lucide.createIcons()` is still called after insertion
- Verify event delegation picks up new dropdown interactions automatically

---

## 4. Risk Controls

### Edge Cases
- **Product with zero variations**: Only the "+" button renders, no dropdowns. Template must handle `{% if product.variations %}` guard correctly. The "+" button must still be positioned consistently.
- **Product with many variations (3+)**: Multiple dropdowns must stack without overflowing the image area on desktop. Consider horizontal scrolling or wrapping behavior for the dropdown row.
- **Dropdown clipping**: Dropdowns positioned absolute inside the image container (which has `overflow-hidden`) will be clipped. The dropdown list must open in a direction that avoids clipping OR the overflow must be selectively managed.
- **Swiper carousel slide height on mobile**: Cards in `home-product-carousel.tpl` will have variable heights on mobile if some products have variations and others don't. Swiper may need `autoHeight: true` or cards must have a consistent minimum height.
- **Infinite scroll deduplication**: The current `fetchedUrls` deduplication set and `data-product-id` based extraction must still work when using raw HTML extraction. Verify no duplicate product IDs are inserted.
- **Selected option tracking**: Dropdowns must visually show which option was selected (update trigger text to selected option name). This is purely visual — no server state is modified.

### Regression Zones
- **Category infinite scroll**: Changing from `extractProducts()`+`renderCard()` to raw HTML extraction could break if the fetched page template structure differs from expectations. Must verify the fetched page uses the same `item-card.tpl` template and has `.js-category-grid` with `[data-product-id]` children.
- **Product carousel**: Cards inside Swiper carousels must not break Swiper's layout calculations. Test with Swiper after adding the quick-buy structure.
- **Existing dropdown modules**: `category-dropdown.js` and `product-carousel.js` dropdown use different `js-*` prefixes (`js-category-dropdown-*`, `js-carousel-dropdown-*`). The new `js-quickbuy-dropdown-*` classes must not conflict.
- **Lucide icon rendering**: The `plus` and `chevron-down` icons in statically rendered cards are handled by the initial `lucide.createIcons()` call in `layout.tpl`. Dynamically loaded cards (infinite scroll) rely on the existing re-init call at line 278-280.

### Strict Non-Modification Areas
- `__src/js/modules/system/header.js` — no changes
- `__src/js/modules/system/menu.js` — no changes
- `__src/js/modules/system/search.js` — no changes
- `__src/js/modules/system/modal.js` — no changes
- `__src/js/modules/system/toast.js` — no changes
- `__src/js/modules/home/hero-banner-2-carousel.js` — no changes
- `__src/js/modules/home/product-carousel.js` — no changes (Swiper config may need review but NOT modification in this feature)
- `__src/js/modules/category/category-dropdown.js` — no changes
- `__src/js/modules/category/category-filters.js` — no changes
- `config/settings.txt` — no changes (no new admin settings for this feature)
- `layouts/layout.tpl` — no changes
- `esbuild.config.mjs` — no changes
- `pre-build.js` — no changes
- Any file in `static/` — never edit directly (A4)
