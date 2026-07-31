# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A8, A9, S2, S3, R3, R4, F4, D1

### Invariant Tension Check

1. **A5/S2 — Contract Out of Date**: The `cart-drawer.js` module already registers 3 `window.*` globals (`openCartDrawer`, `closeCartDrawer`, `onCartUpdate`) that are NOT in the current A5/S2 registry (7 globals). The registry must be updated to 10 globals as part of this work. This is a documentation gap, not an architectural violation — the globals already exist and follow the correct pattern.

2. **A8/F4 — Frosted-glass color**: The header active state uses `rgba(255, 255, 246, 0.7)` at `app.css:91` — this is a KNOWN BUG listed in A8. Applying frosted-glass to the cart drawer MUST use `color-mix(in srgb, var(--background-color) 70%, transparent)` instead of copying the buggy value. This aligns with fixing A8 bug #1.

3. **A8/F4 — "Dark burgundy" color**: The "bordo escuro dos menus" is `var(--primary-color)`, which maps to `--color-fg` in the `@theme` block. The drawer already uses `text-fg` and `bg-fg` classes. No new color token is needed — the current classes already reference the correct color. The request may be about ensuring consistency or changing specific elements that currently use a different color.

4. **S3 — Desktop top offset**: The cart drawer desktop `top` offset must be computed at runtime (header height varies). Per S3 rule 5, `element.style.top` is the correct mechanism for runtime-computed values.

No architectural violation is required. All changes fit within existing patterns.

### Risk Level
**MEDIUM**

- Z-index reordering affects global stacking context
- Cross-module dependency addition (toast → cart drawer)
- Desktop repositioning changes spatial relationship with header
- Architecture contract needs documentation update (3 undocumented globals)

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
No changes required. All data flows through existing platform template variables and DOM attributes.

### 2.2 State / Hooks

**Modify: `__src/js/modules/system/cart-drawer.js`**
- Add desktop-specific logic in `openDrawer()` to compute header height and apply `top` offset to `.js-cart-drawer-panel` via `element.style.top`
- Add `resize` event listener (debounced) to recalculate `top` offset while drawer is open on desktop
- On close, reset `element.style.top` to avoid stale values
- Why: Desktop drawer must open below header, and header height is dynamic (advertising bar presence, resize). Per S3, `element.style.top` is correct for runtime-computed values
- Constrained by: A1 (changes in `__src/js/modules/system/`), A2 (DOM guard already exists), S3 (element.style for computed values), D1 (reads header height from DOM via `offsetHeight`)

**Modify: `__src/js/modules/system/toast.js`**
- Add a click event listener to product toast elements (the toast body, excluding the close button) that calls `window.openCartDrawer?.()` and `window.closeToast?.(toastElement)`
- Why: Clicking a product toast (from quickbuy) should open the cart drawer for immediate checkout flow
- Constrained by: A5/S2 (must use `window.openCartDrawer?.()` with optional chaining), R1 (no horizontal imports — toast must NOT import from cart-drawer)

**Modify: `docs/architecture-map.md`**
- Update A5 and S2 registries to include 3 new globals: `window.openCartDrawer()`, `window.closeCartDrawer()`, `window.onCartUpdate(callback)` — total becomes 10
- Add `cart-drawer.js` to A2 guard registry: `.js-cart-drawer`
- Update A3 import count if any new exports are added (currently not expected)
- Why: Contract must reflect actual codebase state before adding new cross-module consumers
- Constrained by: A5/S2 (all window.* globals must be documented)

### 2.3 UI / Components

**Modify: `snipplets/cart/cart-drawer.tpl`**
- Remove `border-b border-black/8` from the header div (line 13)
- Remove `border-t border-black/8` from the footer div (line 121)
- Add structural classes to footer div for sticky positioning: replace current classes to include `sticky bottom-0 bg-bg` (the footer needs its own background to avoid content showing through when scrolling)
- Why: Design requirement to remove borders and fix footer at bottom of drawer
- Constrained by: R3 (all `js-*` classes and `data-*` attributes must remain intact for platform bindings)

**Modify: `snipplets/header/header-new.tpl`**
- Add a mobile-visible cart count badge near the shopping-cart icon. Add a new `<span>` element with `js-cart-widget-amount` class (or a sibling element) that is visible on mobile (`md:hidden` or no hidden class) showing `{{ cart.items_count }}` when cart has items
- Why: Mobile users currently have no visual indicator of cart item count
- Constrained by: R3 (must use `js-cart-widget-amount` or a parallel class that the platform can update via AJAX), A10 (snipplet organization)

### 2.4 Styling

**Modify: `__src/css/app.css` — `@theme` block**
- Swap z-index values: `--z-cart-drawer: 90` and `--z-toast: 80`
- Why: Cart drawer must render above toast notifications
- Constrained by: A8 (theme tokens are the single source of z-index values)

**Modify: `__src/css/app.css` — header active state (line 91)**
- Fix A8 bug #1: Replace `rgba(255, 255, 246, 0.7)` with `color-mix(in srgb, var(--background-color) 70%, transparent)`
- Why: This is a known bug in A8. Fixing it here is necessary because the cart drawer frosted-glass must reference the correct pattern, not copy the buggy value
- Constrained by: A8/F4 (theme-dependent colors NEVER hardcoded)

**Modify: `__src/css/app.css` — cart drawer styles**
- Add desktop-only frosted-glass styles for `.js-cart-drawer-panel`: `backdrop-filter: blur(0.5rem)` and `background-color: color-mix(in srgb, var(--background-color) 70%, transparent)` behind a `@media (min-width: 768px)` query. On mobile, keep `bg-bg` (solid background)
- Why: Desktop drawer should match header's frosted-glass aesthetic
- Constrained by: A8/F4 (must use CSS custom properties, not hardcoded colors), A9 (cart drawer uses data-state pattern)

**Modify: `__src/css/app.css` — quantity input width fix**
- Add CSS rules to stabilize the quantity input container width: set a fixed `min-width` on the quantity control container (the `div.flex` wrapping minus/input/spinner/plus) and ensure the `.js-cart-input-spinner` does not affect layout when toggled (e.g., `position: absolute` or fixed dimensions on the container)
- Why: Platform spinner show/hide causes layout shift in quantity controls
- Constrained by: F4 (no hardcoded colors), R3 (must not remove or rename `js-cart-input-spinner` — platform depends on it)

**Modify: `snipplets/cart/cart-drawer.tpl` — text/button color classes**
- Review and ensure text and button elements use `text-fg` and `bg-fg` consistently. The checkout button already uses `bg-fg text-bg`. If any elements use different color classes, update them to use `text-fg`
- Why: Ensure consistent "dark burgundy" (which IS `--color-fg` / `--primary-color`) across the drawer
- Constrained by: A8/F4 (colors must come from theme tokens)

### 2.5 Assets
No changes required. No new icons or images needed.

---

## 3. Execution Phases

**Phase 1: Foundation (z-index + color fix + contract update)**
- Swap `--z-cart-drawer` and `--z-toast` values in `@theme` block
- Fix A8 bug #1: Replace hardcoded `rgba(255, 255, 246, 0.7)` with `color-mix()` in header active state
- Update `docs/architecture-map.md` A5/S2 registries with 3 cart-drawer globals
- **Testable**: Header frosted-glass still works visually; toast notifications still appear; cart drawer still opens/closes; z-index ordering is correct (drawer above toasts)

**Phase 2: Template & CSS changes (borders, footer, badge, frosted-glass, quantity fix)**
- Remove border classes from drawer header and footer in `cart-drawer.tpl`
- Add sticky positioning to footer in `cart-drawer.tpl`
- Add mobile cart count badge in `header-new.tpl`
- Add desktop frosted-glass CSS for cart drawer panel in `app.css`
- Add quantity input width stabilization CSS in `app.css`
- Verify/fix text and button color consistency in `cart-drawer.tpl`
- **Testable**: Drawer visually correct (no borders, sticky footer, frosted panel on desktop); mobile badge visible; quantity controls stable during loading

**Phase 3: JS behavior changes (desktop positioning, toast click)**
- Modify `cart-drawer.js` to compute and apply header-height `top` offset on desktop
- Add resize listener for dynamic header height recalculation
- Modify `toast.js` to add click handler on product toasts that opens cart drawer
- **Testable**: Desktop drawer opens below header; clicking product toast opens cart drawer; resize maintains correct drawer position

---

## 4. Risk Controls

### Edge Cases
- **Empty cart state**: Footer is hidden when cart is empty (`display:none` via platform). Sticky positioning must not break the empty cart centered layout
- **Advertising bar toggling**: Header height changes when ad bar is present/absent. Desktop drawer `top` offset must account for both states
- **Rapid toast click + close**: Clicking a product toast to open cart while toast is in "exiting" state — must guard against double-open or race conditions
- **Resize between mobile/desktop**: Drawer open on desktop → resize to mobile breakpoint. Must clear `element.style.top` on mobile to avoid mispositioned drawer
- **Multiple product toasts**: Only the clicked toast should trigger cart open, not all visible toasts
- **Cart count badge with 0 items**: Mobile badge should be hidden or show nothing when cart is empty
- **Platform AJAX cart updates**: The platform updates `.js-cart-widget-amount` via AJAX. The mobile badge element must use a class/structure that the platform's `store.js.tpl` recognizes for updates

### Regression Zones
- **Toast system**: Z-index change means toasts now appear BELOW cart drawer. Verify toasts are still visible when cart is closed (no z-index conflict with other elements at z-80)
- **Modal system**: `--z-modal: 100` remains unchanged. Verify modal still appears above cart drawer (z-90) — should be fine since 100 > 90
- **Header scroll behavior**: Fixing the hardcoded background color in header active state could subtly change the visual appearance on light themes where `--background-color` is close to but not exactly `#FFFFF6`
- **Cart drawer open/close animations**: Adding `top` offset and frosted-glass must not break the existing `translateX` slide animation
- **Platform cart operations**: `LS.minusQuantity`, `LS.plusQuantity`, `LS.removeItem` — all platform AJAX operations on cart items must continue working after template changes

### Strict Non-Modification Areas
- `static/js/store.js.tpl` — platform-managed, handles cart AJAX operations
- `static/js/external.js.tpl` — platform-managed dependencies
- `__src/js/modules/system/item-card-quickbuy.js` — not in scope, quickbuy system unchanged
- `__src/js/modules/system/modal.js` — not in scope, modal system unchanged
- `__src/js/index.js` — no new module exports expected, import structure unchanged
- `config/settings.txt` — no new settings needed (all colors come from existing theme tokens)
- `.js-cart-item`, `.js-ajax-cart-panel`, `.js-ajax-cart-list`, `.js-empty-ajax-cart`, `.js-cart-input-spinner`, `.js-subtotal-price`, `.js-ajax-cart-total`, `.js-cart-subtotal` — platform-bound classes, must NOT be removed or renamed
- `data-store`, `data-component`, `data-item-id`, `data-priceraw` attributes — platform data bindings, must NOT be modified
