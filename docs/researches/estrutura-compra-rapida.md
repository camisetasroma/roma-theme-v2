# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Replace the current non-functional shopping cart icon button on `item-card.tpl` with a **quick-buy structure** consisting of:

- **Variation dropdowns**: For each product variation (`product.variations`), render a `<select>`-style dropdown allowing the user to pick an option (e.g., Size, Color).
- **Add-to-cart button**: A "+" icon button placed next to the dropdowns. This button has **no behavior for now** — it will be implemented when the cart feature is built.
- **Responsive layout**: On desktop, the dropdowns and button overlay the product image (bottom area). On mobile, the dropdowns and button are placed **below** the product image (outside the image container) to accommodate multiple dropdowns without cramping.
- **Products without variations**: If a product has no variations (`product.variations` is empty), the dropdowns are not rendered. Only the "+" button should appear.

The feature applies to all contexts where `item-card.tpl` is included: home product grid, home product carousel (3 tabs), and category page grid (including dynamically loaded cards via infinite scroll).

## 2. Assumptions (if any)

1. **Dropdown style follows existing pattern**: The new variation dropdowns will follow the same visual pattern as the existing `js-carousel-dropdown` and `js-category-dropdown` components (pill-shaped trigger, chevron icon, absolute-positioned list, backdrop-blur background).
2. **No server interaction yet**: The "+" button is purely structural — no `fetch()`, no cart API, no `LS.*` calls. Behavior will be added in a future cart feature.
3. **Variation data is available in template scope**: `product.variations` is accessible within `item-card.tpl` since `product` is passed via the parent include context (confirmed by existing usage in `item.tpl` and `product-variants.tpl` in the same codebase).
4. **Dropdown JS behavior**: A new JS module will be needed to handle open/close toggling of these dropdowns, since there will be multiple dropdown instances per page (one per variation per product card). The existing `category-dropdown.js` only handles a single dropdown. A new module scoped to `item-card` dropdowns is expected.
5. **The "+" button replaces the shopping cart icon button entirely** — the old cart icon button is removed, not kept alongside.
6. **"Grid simple"** refers to `home-product-grid.tpl` (the 2x2 product grid on the homepage), not a separate template.

## 3. Affected Architectural Domains

| Domain | Scope |
|---|---|
| **Template Layer** | `snipplets/grid/item-card.tpl` — primary modification target |
| **JS Module Layer** | New module needed in `__src/js/modules/` for dropdown open/close behavior |
| **JS Entry Point** | `__src/js/index.js` — must import and invoke the new module |
| **CSS Layer** | `__src/css/app.css` — may need responsive styles for mobile layout shift |
| **Infinite Scroll** | `__src/js/modules/category/category-infinite-scroll.js` — dynamically fetched cards must also have dropdown behavior initialized |
| **Lucide Icons** | New icon usage (`plus` icon for the add button, `chevron-down` for dropdowns) |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S2, S3, L5, R1, R3, F4, F5, F6, F9

## 5. Invariant Impact Explanation

- **A1**: New JS module must be placed in `__src/js/modules/` under an appropriate context directory. Since item-card is used across home, category, and potentially other pages, the module belongs in `system/` (global) rather than `home/` or `category/`.
- **A2**: The new module must guard execution with a root DOM element check (`if (!element) return;`).
- **A3**: The new module must be a named export, imported and invoked in `index.js`. No self-execution.
- **A5 / S2**: If the future "+" button needs to communicate with a cart module, it must use `window.*` globals. For now, no cross-module communication is needed since the button is inert.
- **A6**: The item-card template already uses `<i data-lucide="...">`. If dropdowns are inserted dynamically (e.g., via infinite scroll), `lucide.createIcons()` must be called after insertion. The infinite scroll module already does this (line 278-280).
- **A8 / F4**: Dropdown backgrounds must NOT use hardcoded colors like `rgba(255,255,246,0.7)` (which is a known bug in existing dropdowns). Must use `color-mix()` with CSS custom properties or Tailwind tokens.
- **A9 / S3**: Dropdown open/close state should use `hidden` attribute (preferred mechanism per S3) and `aria-expanded`, consistent with the existing dropdown pattern in `category-dropdown.js`.
- **A14 / F5**: Icons must use Lucide (`<i data-lucide="plus">`, `<i data-lucide="chevron-down">`). No new SVG snipplets.
- **D1**: JS reads variation data from `data-*` attributes rendered by the template. No direct platform API calls.
- **L5**: Vanilla JS only. No jQuery.
- **R1 / F9**: No horizontal imports between modules. The new module must be standalone.
- **R3**: New `js-*` classes introduced in the template become a binding contract. Must be documented.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- **Infinite scroll re-initialization**: The category infinite scroll dynamically appends item-card HTML. The new dropdown JS must either use event delegation on a parent container or re-initialize after each fetch. The current infinite scroll module calls `lucide.createIcons()` but does not re-initialize any card-level JS. A coordination mechanism (event delegation or a `window.*` re-init function) is required.
- **Multiple dropdowns per card**: Unlike existing dropdown patterns (single dropdown per context), each card can have N dropdowns (one per variation). The JS module must handle scoped instances, not global singletons.
- **Mobile layout restructure**: Moving the dropdowns below the image on mobile changes the card's visual layout significantly. This affects the Swiper carousel slide height consistency (carousel slides must have uniform height or Swiper configuration must accommodate variable heights).
- **Existing bug propagation**: The existing dropdown pattern uses `rgba(255,255,246,0.7)` which is a known bug (A8). The new dropdowns must NOT copy this pattern.

## 7. Likely Impacted Areas (Scoped)

| File | Impact |
|---|---|
| `snipplets/grid/item-card.tpl` | **Modified** — add variation dropdowns and "+" button, restructure layout for mobile |
| `__src/js/modules/system/item-card-quickbuy.js` (new) | **Created** — dropdown toggle logic for variation selectors, scoped per card |
| `__src/js/index.js` | **Modified** — import and invoke new module |
| `__src/css/app.css` | **Possibly modified** — responsive styles if Tailwind utilities alone are insufficient |
| `__src/js/modules/category/category-infinite-scroll.js` | **Possibly modified** — may need to call a re-init function after appending new cards (if event delegation is not used) |

## 8. Visual / Component Surface Impact

- **Desktop**: Variation dropdowns and "+" button overlay the product image at the bottom (replacing the current cart icon button). Multiple dropdowns stack horizontally or in a row.
- **Mobile**: Variation dropdowns and "+" button move **below** the product image, inside the card but outside the image container. This increases the card's vertical height on mobile.
- **Carousel impact**: Cards inside Swiper carousels (`home-product-carousel.tpl`) will have taller slides on mobile. Swiper's `autoHeight` or fixed height strategy must be considered.
- **Grid impact**: Cards in `home-product-grid.tpl` and `category.tpl` grid will grow vertically on mobile. CSS grid/flexbox should handle this naturally.
- **Products without variations**: Only the "+" button appears — no dropdowns. The button should be positioned consistently with the dropdown+button layout.

## 9. Architectural Constraints Summary

1. New JS module MUST go in `__src/js/modules/system/` (global scope since item-card appears on multiple page types).
2. Module MUST be a named export with DOM guard, imported in `index.js` under `//System` group.
3. Dropdown behavior MUST use `hidden` attribute + `aria-expanded` for state (S3 preference order).
4. Dropdown backgrounds MUST use CSS custom properties or Tailwind tokens — NOT hardcoded rgba values.
5. Icons MUST use Lucide (`plus`, `chevron-down`).
6. Variation data MUST be read from template-rendered `data-*` attributes or DOM structure — no `LS.*` or AJAX calls.
7. The "+" button MUST be inert (no behavior) until the cart feature is implemented. Future cart integration will use `window.*` globals per A5/S2.
8. Dynamic card insertion (infinite scroll) MUST be handled — either via event delegation (preferred) or a `window.*` re-init function exposed by the new module.
9. No horizontal module imports — the new module is standalone.
10. `lucide.createIcons()` MUST be called if dropdown HTML is inserted dynamically (already handled by infinite scroll for the card itself).
