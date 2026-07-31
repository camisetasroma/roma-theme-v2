# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

When the user clicks the `.js-quickbuy-add-btn` (plus button) in the quickshop component on product cards, a toast notification must appear displaying:
- Product image (thumbnail)
- Product name
- Product price
- Product quantity (1, since this is a single add action)

This is a visual-only animation/feedback feature. No actual cart logic will be implemented — this is a placeholder interaction that will later be connected to the cart system when it is ready. The toast must use the existing `window.showToast()` API from `toast.js`.

## 2. Assumptions (if any)

- **Toast content format change**: The current `showToast()` API accepts `{ message, icon, duration }` with a simple text message. The feature requires a structured layout (image + name + price + quantity), which the current API does NOT support. The toast system will need to be extended to accept either rich HTML content or a structured product object.
- **Quantity is always 1**: Since there is no cart logic yet, each click represents adding 1 unit.
- **Product data source**: Product data (name, price, image) will be read from the DOM of the parent `.js-item-product` card element, using existing `data-*` attributes and rendered HTML content.
- **No cart state mutation**: No `localStorage`, no `LS.*` calls, no form submissions. This is purely a visual feedback toast.
- **The plus button currently has no behavior**: This will be its first attached functionality, handled in `item-card-quickbuy.js`.

## 3. Affected Architectural Domains

- **JS Module**: `__src/js/modules/system/item-card-quickbuy.js` — Will need a click handler on `.js-quickbuy-add-btn`
- **JS Module**: `__src/js/modules/system/toast.js` — Will need API extension to support structured/rich content (image + text layout) beyond the current simple `{ message, icon }` format
- **CSS**: `__src/css/app.css` — May need styling for the new toast product layout variant
- **Template**: `snipplets/grid/item-card.tpl` — May need additional `data-*` attributes on the card or button to expose product image/name/price to JS

## 4. Applicable Invariants (Codes Only)

A1, A2, A5, A6, A8, A9, S2, S3, D1, R3, F4, F9, L5

## 5. Invariant Impact Explanation

- **A1**: Any new JS must stay within `__src/js/modules/`. The quickbuy handler already lives in `system/item-card-quickbuy.js` — changes stay there.
- **A2**: `item-card-quickbuy.js` already has DOM guards. New functionality must respect the existing guard pattern.
- **A5 / S2**: The toast must be triggered via `window.showToast?.()` (optional chaining). No direct import from `toast.js`.
- **A6**: If the toast renders any `<i data-lucide="...">` icons, `lucide.createIcons()` must be called after insertion — already handled inside `toast.js:70-72`.
- **A8 / F4**: Any colors in the new toast layout must use CSS custom properties or Tailwind tokens. No hardcoded hex/rgba theme-dependent values.
- **A9**: Toast state transitions (`entering` → `visible` → `exiting`) via `data-state` must be preserved for the new content variant.
- **S3**: UI state mechanisms must follow preference order: `hidden` > `data-state` > `aria-expanded` > `classList` > `element.style`.
- **D1**: Product data must be read from DOM (`data-*` attributes, element content, or `getComputedStyle`). No `LS.*` or AJAX calls.
- **R3**: `.js-quickbuy-add-btn` is already part of the binding contract between `item-card-quickbuy.js` and `item-card.tpl`. Any new `js-*` classes must be documented.
- **F9**: `item-card-quickbuy.js` must NOT import from `toast.js`. Communication goes through `window.showToast?.()`.
- **L5**: Vanilla JS only. No jQuery.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale: The current `showToast()` API does not support structured/rich content (product image + name + price + quantity layout). Extending the toast system introduces a new content paradigm that must maintain backward compatibility with existing simple text toasts. The change to `toast.js` affects a cross-module system (`window.showToast` is a registered global in A5/S2), so the API surface change must be carefully designed to avoid breaking existing consumers.

## 7. Likely Impacted Areas (Scoped)

| File | Change Type |
|------|-------------|
| `__src/js/modules/system/item-card-quickbuy.js` | Add click handler on `.js-quickbuy-add-btn` to read product data from DOM and call `window.showToast?.()` |
| `__src/js/modules/system/toast.js` | Extend `showToast()` API to accept structured product content (image, name, price, quantity) alongside existing simple message format |
| `__src/css/app.css` | Add styles for the product toast layout variant (image + text grid within toast) |
| `snipplets/grid/item-card.tpl` | Possibly add `data-*` attributes to expose product image URL, name, and price to JS if not already accessible via DOM traversal |

## 8. Visual / Component Surface Impact

- **Toast component**: New layout variant showing a horizontal card with product thumbnail (left), and name/price/quantity stacked (right). This is a new visual pattern within the existing toast container.
- **Toast dimensions**: The current toast has a fixed width of `241px` and `minHeight: 77px`. The product toast variant with an image may require adjusted dimensions.
- **No impact on**: Header, modal, search overlay, menu, product carousel, category pages, or any other existing visual component.
- **Animation**: Reuses existing toast `data-state` transitions (`entering` → `visible` → `exiting`). No new animations required.

## 9. Architectural Constraints Summary

1. The `showToast()` API extension must be **backward-compatible** — existing calls with `{ message, icon, duration }` must continue to work unchanged.
2. Product data must be extracted from the DOM, not from any API call or platform function.
3. The plus button handler must live in `item-card-quickbuy.js` and communicate with the toast system exclusively via `window.showToast?.()`.
4. If the toast API signature changes (new parameters), the `window.showToast` global registry in the architecture contract (A5, S2) must be updated to reflect the new accepted options.
5. All styling must use CSS custom properties or Tailwind tokens — no hardcoded theme-dependent colors.
6. The product image in the toast must be sourced from an `<img>` element or `data-*` attribute already rendered in the template, not fetched separately.
