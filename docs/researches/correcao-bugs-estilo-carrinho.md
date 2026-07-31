# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

This feature request encompasses **8 distinct style/behavior bug fixes** for the cart drawer system:

1. **Mobile item count badge**: Add a visible item count indicator on the cart icon in mobile view (currently only desktop shows `({{ cart.items_count }})` via `.js-cart-widget-amount` which has `hidden md:inline`).

2. **Desktop drawer positioning & styling**: On desktop, the cart drawer should open **below the header** (not over it) and inherit the header's frosted-glass styling (backdrop-filter blur + semi-transparent background). Currently the drawer is `fixed inset-0 z-80` which covers the header.

3. **Cart z-index above toasts**: The cart drawer must render **above** toast notifications. Currently `--z-cart-drawer: 80` and `--z-toast: 90`, meaning toasts appear above the cart. Z-index values need to be swapped or adjusted.

4. **Product toast click opens cart**: When clicking the quickbuy product toast, the cart drawer should open. Currently the toast has no click handler to trigger `window.openCartDrawer()`.

5. **Text and button color to dark burgundy**: Change text and button colors inside the cart drawer from current `text-fg` / `bg-fg` to the dark burgundy used in navigation menus. This must use a CSS variable or theme token — NOT a hardcoded hex.

6. **Remove borders from drawer header and footer**: Remove the `border-b border-black/8` from the drawer header div and the `border-t border-black/8` from `.js-cart-drawer-footer`.

7. **Fixed subtotal/checkout footer**: The footer container (subtotal + checkout button) must be **sticky/fixed** at the bottom of the drawer, with only the items list scrolling. The current structure already uses `flex-col` and `min-h-0` on the form, and `flex-1 overflow-y-auto` on the items list — this may already work but needs verification or CSS adjustment.

8. **Quantity input width stability during loading**: When the platform spinner (`.js-cart-input-spinner`) shows/hides during quantity change operations, the quantity input container jumps in width. The input and its container need fixed dimensions to prevent layout shift.

## 2. Assumptions (if any)

- **A-1**: "Bordo escuro usado nos menus" refers to a color already defined as a CSS custom property or available via the theme color system. If it's currently a hardcoded value in menu styles, it must be extracted to a theme token first per F4/A8.
- **A-2**: "Drawer abrir abaixo do header" on desktop means the drawer panel should have `top` offset equal to the header height (not `top: 0`), not that it is positioned inside the header element.
- **A-3**: "Mesmos estilos do header com transparencia e blur de fundo" refers to the frosted-glass effect on `.js-new-header[data-state="active"]` (`backdrop-filter: blur()` + semi-transparent `background-color`).
- **A-4**: "Ao clicar no toast" refers specifically to clicking the product toast body (not the close X button), which should open the cart drawer.
- **A-5**: The quantity input width bug is caused by the platform's `.js-cart-input-spinner` element toggling `display:none` and displacing the input — a fixed width on the container should resolve it.
- **A-6**: "Carrinho abrir acima dos toasts" means the z-index of the cart drawer should be higher than the toast z-index when the drawer is open.

## 3. Affected Architectural Domains

| Domain | Affected |
|--------|----------|
| **Template Layer** | `snipplets/cart/cart-drawer.tpl` (borders, mobile badge, footer structure) |
| **Template Layer** | `snipplets/header/header-new.tpl` (mobile cart count badge) |
| **CSS Layer** | `__src/css/app.css` (z-index tokens, drawer positioning, frosted-glass styles, quantity input width fix) |
| **JS Module** | `__src/js/modules/system/cart-drawer.js` (desktop drawer top offset, header-aware positioning) |
| **JS Module** | `__src/js/modules/system/toast.js` (click handler on product toast to open cart) |
| **Cross-module** | Toast → Cart Drawer communication via `window.openCartDrawer()` |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, S2, S3, R3, R4, F4, D1

## 5. Invariant Impact Explanation

| Invariant | Impact |
|-----------|--------|
| **A1** | All JS changes must remain within `__src/js/modules/system/`. No new module context needed — changes affect existing `cart-drawer.js` and `toast.js`. |
| **A2** | Both modules already have DOM guards. No change required. |
| **A3** | No new module exports needed. The existing `cartDrawerSystem` and `toastSystem` exports remain unchanged. Import count stays at 14. However, `window.openCartDrawer` is a new `window.*` global (already registered in cart-drawer.js but NOT listed in A5/S2 contract). The contract must be updated to include 3 new globals: `openCartDrawer`, `closeCartDrawer`, `onCartUpdate`. |
| **A5/S2** | **CONTRACT UPDATE REQUIRED.** The cart-drawer module already registers 3 `window.*` globals (`openCartDrawer`, `closeCartDrawer`, `onCartUpdate`) that are NOT in the current registry (7 globals). The registry must be updated to 10 globals. Adding a toast click → `window.openCartDrawer?.()` call in `toast.js` creates a new cross-module dependency. |
| **A6** | If any innerHTML is modified in cart-drawer, `lucide.createIcons()` must be called (already done in `syncMeta`). |
| **A8/F4** | The "dark burgundy" color MUST come from a CSS variable or theme token. Hardcoding a hex value is forbidden. If this color is not already a theme token, a new token must be added to `@theme` in `app.css`, mapped from a platform CSS custom property or `settings.txt`. |
| **A9** | Cart drawer already uses `data-state="open|closed"` pattern. No change to the pattern. New CSS rules for desktop positioning can key off `data-state="open"`. |
| **S3** | Desktop top-offset is a computed value (header height) → `element.style.top` is the correct mechanism per S3 rule 5. |
| **R3** | No new `js-*` classes are expected. Existing binding contracts remain intact. |
| **R4** | New CSS selectors in `app.css` targeting `.js-cart-drawer-*` must follow existing patterns. |
| **D1** | Cart-drawer.js already reads header height from DOM via `offsetHeight`. This is permitted. |

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

- **Z-index reordering** (cart above toasts) affects the global stacking context. Any change to `--z-cart-drawer` and `--z-toast` values impacts all components using these tokens. Must verify no other components depend on the toast-above-cart ordering.
- **Cross-module dependency** (toast click → `window.openCartDrawer()`) adds a new consumer relationship that must be documented in A5/S2.
- **Color change** requires identification of the exact "dark burgundy" source. If it's a hardcoded value in existing menu styles, that itself is an A8 violation that needs resolution first.
- **Desktop drawer repositioning** (below header) changes the spatial relationship between header and drawer, which could affect scroll behavior, menu dropdowns, and mobile menu interactions.
- **Architecture contract is out of date** — the cart-drawer module's 3 `window.*` globals are not registered in A5/S2. This must be reconciled.

## 7. Likely Impacted Areas (Scoped)

| File | Change Type |
|------|-------------|
| `__src/css/app.css` — `@theme` block | Z-index token values swap/adjust (`--z-cart-drawer`, `--z-toast`); possible new color token for burgundy |
| `__src/css/app.css` — cart drawer styles | Desktop-specific `top` offset rule; frosted-glass styles on panel; quantity input width fix |
| `snipplets/cart/cart-drawer.tpl` | Remove `border-b` from header div; remove `border-t` from footer div; verify footer is structurally fixed at bottom |
| `snipplets/header/header-new.tpl` | Add mobile-visible cart count badge (modify `.js-cart-widget-amount` classes or add new element) |
| `__src/js/modules/system/cart-drawer.js` | Compute and apply `top` offset based on header height for desktop; possibly listen for resize |
| `__src/js/modules/system/toast.js` | Add click event on product toast body to call `window.openCartDrawer?.()` |
| `docs/architecture-map.md` | Update A5/S2 globals registry to include `openCartDrawer`, `closeCartDrawer`, `onCartUpdate` (total: 10) |

## 8. Visual / Component Surface Impact

| Component | Visual Change |
|-----------|---------------|
| **Cart icon (mobile)** | Gains a visible item count badge/number near the shopping-cart icon |
| **Cart drawer panel (desktop)** | Starts below header instead of at `top: 0`; background becomes frosted-glass (blur + semi-transparent) matching header's active state |
| **Cart drawer panel (all)** | Header section loses bottom border; footer section loses top border; text and button colors shift to dark burgundy |
| **Cart drawer footer** | Becomes visually fixed at bottom — items list scrolls independently above it |
| **Cart quantity controls** | Input container maintains stable width during loading spinner show/hide; no visual jump |
| **Toast notifications** | Now render below the cart drawer (z-index change); product toasts become clickable to open cart |

## 9. Architectural Constraints Summary

1. **Z-index changes are global**: Swapping `--z-cart-drawer` and `--z-toast` in `@theme` affects every element using these tokens. There must be no secondary consumers that rely on the current ordering.

2. **Color must be tokenized**: The "dark burgundy" color cannot be hardcoded per A8/F4. It must either map to an existing platform CSS variable (e.g., `--primary-color`) or be added as a new setting in `settings.txt` → `style-colors.scss.tpl` → `@theme`. If it already exists as a theme variable, use that directly.

3. **Cross-module communication via `window.*` only**: The toast → cart interaction must use `window.openCartDrawer?.()` with optional chaining per A5/S2. The toast module must NOT import from cart-drawer.

4. **Architecture contract update mandatory**: Three undocumented `window.*` globals from `cart-drawer.js` must be added to the A5 and S2 registries before or alongside this work.

5. **Desktop drawer repositioning must be dynamic**: Header height varies (advertising bar presence, resize). The `top` offset must be computed at open-time and updated on resize, similar to how `toast.js` already does `container.style.top = headerHeight + "px"`.

6. **Template changes must preserve platform bindings**: All `.js-*` classes and `data-*` attributes in `cart-drawer.tpl` that the platform (LS.*) depends on must remain intact. Only visual/structural classes may be changed.

7. **Quantity input fix must not break platform spinner**: The `.js-cart-input-spinner` is toggled by the platform's `store.js.tpl`. The fix must use CSS-only width stabilization (e.g., fixed `min-width` on the container or input) without hiding or removing the spinner element.
