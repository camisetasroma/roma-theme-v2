# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Add an order bump product carousel inside the cart drawer. The carousel displays products from a dedicated catalog (section) configured via `sections.txt`, allowing the store admin to curate the product list through the Nuvemshop admin panel. The carousel reuses the same visual structure as the home product carousel (`home-product-carousel.tpl`), but simplified to a single catalog (no tabs). The carousel must be positioned within the cart drawer body, below the cart items list — NOT in the footer area.

## 2. Assumptions (if any)

- **Single catalog only**: Unlike the home carousel (3 tabs), this carousel loads a single section. No tab switching needed.
- **New section in `sections.txt`**: A new section entry (e.g., `cart_order_bump`) must be added to `config/sections.txt` so the admin can curate products via the Nuvemshop admin.
- **Carousel JS reuse**: The home `product-carousel.js` is tightly coupled to the 3-tab home structure. The cart order bump carousel will likely need its own Swiper initialization logic within `cart-drawer.js` or a new dedicated module under `__src/js/modules/system/`.
- **Cart drawer refresh**: Since `cart-drawer.js` refreshes the cart content via `fetch()` + `DOMParser`, the order bump carousel HTML must be part of the server-rendered cart drawer content so it survives refresh cycles.
- **Quick-buy integration**: If the carousel uses `item-card.tpl` (which includes quick-buy), adding a product from the order bump should trigger `window.onCartUpdate?.()` to refresh the cart drawer.
- **No interaction with home section router**: This carousel is cart-scoped, not homepage-scoped. It does not touch `home-section-switch.tpl` or `settings.home_order_position_*`.

## 3. Affected Architectural Domains

- **Template Layer**: `snipplets/cart/cart-drawer.tpl` (insertion point), new snipplet in `snipplets/cart/` for the order bump carousel
- **Configuration Layer**: `config/sections.txt` (new section), `config/settings.txt` (optional toggle/title settings), `config/defaults.txt`, `config/translations.txt`
- **Source JS Layer**: `__src/js/modules/system/cart-drawer.js` (Swiper init after refresh, or new module)
- **Source CSS Layer**: `__src/css/app.css` (possible styling for carousel inside drawer context)

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A12, A13, A14, D1, L3, L5, L6, R1, R3, S2, S3, T5, F4, F5, F6, F9

## 5. Invariant Impact Explanation

- **A1**: If a new JS module is created for the cart carousel, it must go in `__src/js/modules/system/` (since cart is a system-level component).
- **A2**: Any new module or function must guard with DOM element existence check.
- **A3**: If a new module is created, it must be a named export, imported and invoked in `index.js`. The export count in the contract must be updated.
- **A5/S2**: If the order bump carousel needs to communicate with other modules (e.g., triggering cart refresh after add-to-cart), it must use existing `window.*` globals (`window.onCartUpdate`). No new globals should be needed.
- **A6**: After the cart drawer refreshes its content via `fetch()`, `lucide.createIcons()` must be called — this already happens in `cart-drawer.js`. If the carousel injects new HTML with lucide icons, the existing refresh flow covers it.
- **A10**: The new snipplet must be placed in `snipplets/cart/`, not at the root of `snipplets/`.
- **A13**: Any new settings must follow `snake_case` naming and proper grouping in `settings.txt`.
- **D1/T5**: Product data must come from the section rendered by the template (`{{ sections.cart_order_bump.products }}`). JS must NOT fetch product data independently.
- **L3**: Swiper must be used via the global constructor, not installed via npm.
- **L5**: Vanilla JS only — no jQuery.
- **L6**: If add-to-cart is needed from the carousel, `LS.addItem()` is permitted in cart modules.
- **R3**: Any new `js-*` classes become binding contracts between templates and JS.
- **F4**: No hardcoded theme-dependent colors.
- **F5**: Icons must use Lucide.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

- The cart drawer refresh mechanism (`fetch()` + replace innerHTML) must account for the new carousel section. If the carousel is inside the refreshed area, Swiper instances will be destroyed and need re-initialization.
- Swiper initialization timing: after cart refresh, Swiper must be re-instantiated for the carousel. This adds complexity to the existing refresh flow.
- The carousel inside a drawer has constrained width — responsive breakpoints from the home carousel may need adjustment for the narrower drawer context.
- Quick-buy from the order bump carousel could create a circular refresh loop if not handled carefully (add item → refresh cart → re-render carousel → user adds again).

## 7. Likely Impacted Areas (Scoped)

| Area | File(s) | Impact |
|------|---------|--------|
| Cart drawer template | `snipplets/cart/cart-drawer.tpl` | Include new carousel snipplet below items list |
| New carousel snipplet | `snipplets/cart/cart-order-bump.tpl` (new) | Single-catalog carousel with item cards |
| Sections config | `config/sections.txt` | New `cart_order_bump` section definition |
| Settings config | `config/settings.txt` | Optional: toggle, title text for order bump section |
| Defaults config | `config/defaults.txt` | Default values for new settings |
| Translations config | `config/translations.txt` | Labels for order bump section |
| Cart drawer JS | `__src/js/modules/system/cart-drawer.js` | Swiper init/re-init for carousel after content refresh |
| CSS | `__src/css/app.css` | Carousel-in-drawer specific styles (width constraints, padding) |
| Entry point | `__src/js/index.js` | Only if new module created (update import count in A3) |

## 8. Visual / Component Surface Impact

- **Cart drawer body**: A new horizontal product carousel appears below the cart items list, above the footer (subtotal/checkout area).
- **Carousel controls**: Seed pagination and prev/next arrows adapted for the narrower drawer width.
- **Product cards**: Same `item-card.tpl` cards used in home carousel, but rendered at smaller sizes due to drawer width constraints. Likely 1.25–2.25 slides per view instead of the home carousel's 2.25–4.25.
- **Scroll behavior**: The carousel is inside the scrollable cart items area, so it scrolls with the cart content. It should have a section header/title to visually separate it from cart items.
- **Empty state**: If the admin has not configured products in the order bump catalog, the entire section should be hidden (no empty carousel shell).

## 9. Architectural Constraints Summary

1. Product data must come from a server-rendered section (`sections.txt`), not fetched via AJAX by JS.
2. The carousel snipplet must live in `snipplets/cart/`, following domain organization (A10).
3. Swiper must be used as a global (L3), not imported.
4. JS must be vanilla only (L5), no jQuery.
5. Cart drawer refresh flow must re-initialize Swiper after replacing innerHTML.
6. `lucide.createIcons()` must be called after carousel HTML is inserted/refreshed (A6).
7. No hardcoded theme colors (F4/A8) — use CSS custom properties or Tailwind tokens.
8. The carousel is NOT a homepage section — it must NOT interact with the home section router (A11/F10).
9. `LS.addItem()` is permitted for add-to-cart from within cart modules (D1/L6).
10. Any new `js-*` CSS classes establish a template↔JS binding contract (R3).
