# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A5, A6, A8, A9, S2, S3, D1, R3, F4, F9, L5

### Invariant Tension Check
- **A5/S2 tension**: The `showToast()` API signature will be extended with new optional parameters (`productImage`, `productName`, `productPrice`, `productQuantity`). This is an additive change — the existing `{ message, icon, duration }` signature remains fully functional. The `window.showToast` global contract (A5/S2) must be updated in documentation to reflect the expanded options object, but no breaking change occurs.
- **No other invariant tensions detected.** The feature stays within `item-card-quickbuy.js` (A1), communicates via `window.showToast?.()` (F9/S2), reads data from DOM (D1), and uses no hardcoded colors (F4/A8).

### Risk Level
**MEDIUM** — Extending a cross-module API (`window.showToast`) that is part of the architectural contract (A5/S2). Backward compatibility must be preserved. The change is additive-only, reducing actual risk.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
- **No changes.** No new data services, no API calls, no `LS.*` usage. Product data is read from existing DOM elements rendered by the template. **(D1)**

### 2.2 State / Hooks

**Modify: `__src/js/modules/system/toast.js`**
- Extend the `showToast()` function signature to accept an optional product object: `{ message, icon, duration, product }` where `product` is `{ image, name, price, quantity }`.
- When `product` is provided, render a product-layout toast (image thumbnail + name + price + quantity) instead of the default message layout.
- The existing `{ message, icon, duration }` path must remain untouched — backward compatibility is mandatory. **(A5, S2)**
- The product toast variant must still use the same `data-state` transitions (`entering` → `visible` → `exiting`). **(A9)**
- If the product layout includes any `<i data-lucide="...">` icons, `lucide.createIcons()` is already called after insertion (line 70-72), so no additional action needed. **(A6)**
- The `escapeHtml()` helper must be applied to product name to prevent XSS.
- Why: The current API only supports simple text messages. The feature requires a structured product card layout within the toast.

**Modify: `__src/js/modules/system/item-card-quickbuy.js`**
- Add a click handler for `.js-quickbuy-add-btn` buttons (both desktop and mobile variants exist in the template).
- On click, traverse up to the parent `[data-product-id]` card element.
- Extract product data from the DOM:
  - **Image**: from the `<img>` element within the card (the product featured image `src` or `data-src` attribute).
  - **Name**: from the product name text element within the card.
  - **Price**: from the price text element within the card.
- Call `window.showToast?.({ product: { image, name, price, quantity: 1 } })`. **(F9, S2, L5)**
- Why: This is the first behavior attached to the add button. It provides visual feedback for the quickbuy action.
- DOM guard already exists at line 2-3. The click handler will use event delegation on `document` (already used in the module for other click handlers). **(A2)**

### 2.3 UI / Components

**Modify: `snipplets/grid/item-card.tpl`**
- Verify that product image, name, and price elements are accessible via DOM traversal from `.js-quickbuy-add-btn`. If any data is not accessible through existing DOM structure, add minimal `data-*` attributes to expose it. Specifically:
  - Add `data-product-name="{{ product.name }}"` on the card root element if the name is not reliably extractable from DOM text content.
  - Add `data-product-price="{{ product.price | money }}"` on the card root element if the price is not reliably extractable.
  - Add `data-product-image="{{ product.featured_image | product_image_url('small') }}"` on the card root element if the image URL is not reliably extractable from the `<img>` element.
- Why: Relying on DOM traversal to find text content is fragile. `data-*` attributes on the card root provide a stable, contract-based interface between templates and JS. **(D1, R3)**
- New `data-*` attributes must be documented in R3 contract.

### 2.4 Styling

**Modify: `__src/css/app.css`**
- No new CSS rules are strictly required — the product toast layout will be styled inline via `Object.assign(element.style, {...})` in `toast.js`, consistent with the existing toast styling pattern (lines 41-53 of `toast.js`).
- The existing `.js-toast-container [data-state]` rules (lines 139-157) will apply automatically to the new product toast variant since it uses the same `data-state` attribute. **(A9)**
- If the product toast width differs from the current `241px`, this will be set inline in `toast.js` for the product variant only.
- All colors must use CSS custom properties: `var(--primary-color)`, `var(--background-color)`, `var(--color-fg-muted)`, etc. **(A8, F4)**
- Why: Maintaining consistency with the existing toast styling approach (inline styles in JS) avoids introducing a second styling pattern for the same component.

### 2.5 Assets
- **No changes.** No new images, icons, or static assets. The product image comes from the DOM. The close button icon (`x`) already exists in the toast. No new Lucide icons needed.

---

## 3. Execution Phases

**Phase 1: Template data exposure**
- Modify `snipplets/grid/item-card.tpl` to add `data-product-name`, `data-product-price`, and `data-product-image` attributes on the `[data-product-id]` card root element.
- Testable: Inspect rendered HTML in browser to confirm data attributes are present and correct.

**Phase 2: Toast API extension**
- Modify `toast.js` to add the product toast variant within `showToast()`.
- When `product` parameter is provided, render the product layout (image + name + price + quantity) instead of the message layout.
- Preserve the existing message-based toast path unchanged.
- Testable: Call `window.showToast({ product: { image: "url", name: "Test", price: "$10", quantity: 1 } })` from browser console. Verify product toast appears with correct layout, transitions work, close button works, auto-dismiss works.

**Phase 3: Quickbuy button handler**
- Modify `item-card-quickbuy.js` to add a click handler on `.js-quickbuy-add-btn`.
- Handler extracts product data from `data-*` attributes on the parent card and calls `window.showToast?.()` with the product object.
- Testable: Click the plus button on a product card. Verify toast appears with the correct product image, name, price, and quantity "1".

---

## 4. Risk Controls

### Edge Cases
- **Product without image**: If `data-product-image` is empty or missing, the toast should still render without an image (graceful degradation — show name/price/quantity only).
- **Product without price**: If `data-product-price` is empty (e.g., `display_price` is false), the toast should still render without the price line.
- **Multiple rapid clicks**: Multiple toasts should stack correctly. The existing toast system already supports multiple active toasts — no special handling needed.
- **Button hidden for sold-out products**: `item-card-quickbuy.js` already hides `.js-quickbuy-add-btn` when all variants are sold out (line 213-216). No toast will fire for sold-out products since the button is not clickable.
- **Infinite scroll adds new cards**: After new product cards are loaded via infinite scroll, the click handler must still work. Using event delegation on `document` (already the pattern in `item-card-quickbuy.js`) ensures this works for dynamically added cards.

### Regression Zones
- **Existing text toasts**: Must verify that `window.showToast({ message: "test", icon: "check" })` still works exactly as before after the API extension.
- **Toast transitions**: The `data-state` transitions must work identically for both toast variants.
- **Quickbuy dropdown behavior**: The existing dropdown open/close/select logic in `item-card-quickbuy.js` must not be affected by the new click handler. The handler for `.js-quickbuy-add-btn` must be a separate delegation branch.
- **Category infinite scroll**: New cards loaded dynamically must have correct `data-*` attributes and functional quickbuy buttons.

### Strict Non-Modification Areas
- `__src/js/modules/system/modal.js` — Not related to this feature
- `__src/js/modules/system/header.js` — Not related to this feature
- `__src/js/modules/system/search.js` — Not related to this feature
- `__src/js/modules/system/menu.js` — Not related to this feature
- `__src/js/modules/home/*` — Not related to this feature
- `__src/js/modules/category/*` — Not related to this feature
- `__src/js/index.js` — No new module to register; changes are within existing modules
- `snipplets/notification/toast.tpl` — Template structure of the toast container should not change
- `config/settings.txt` — No new settings required for this feature
- `static/` — Never edit directly (A4)
