# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Rebuild the category page (`templates/category.tpl`) to align with the new project design system (Tailwind-based), replacing the current broken Bootstrap-based layout. The feature includes:

- **New category header bar**: Displays the category name, a subcategory dropdown navigator (when child categories exist), and a clickable filter link (non-functional for now — filter panel is out of scope).
- **Subcategory dropdown**: Lists "Todos" + direct child categories only (one level deep). When navigating into a child category, that child's own children populate the dropdown. Uses `filter_categories` template variable as the data source (Nuvemshop provides this on category pages). This is similar to the dropdown in `product-carousel.js` but operates as navigation links (anchor redirects) rather than tab switches.
- **New breadcrumb**: A Tailwind-styled breadcrumb replacing the currently disabled one (`breadcrumbs: false` in the embed).
- **New product grid**: Responsive grid — 2 columns on mobile, 3 on medium screens, 4 on large screens. Should reuse or align with the product card component (`snipplets/grid/item-card.tpl`) used on the home carousel where possible.
- **Header color state on non-home pages**: The header (`header-new.tpl`) must start with colored state (`data-state="active"`) on all pages except the home page. Currently it always starts as `transparent`, which makes text invisible on category pages with white backgrounds.
- **Page background**: Switch to the white/cream theme background color (`bg-bg` or equivalent) instead of relying on inherited/legacy styling.
- **Pagination**: Retain infinite scroll / "load more" behavior.
- **Filters**: Only render a clickable "Filtros" link/button — the filter drawer/modal is out of scope for this feature.

## 2. Assumptions (if any)

- **Subcategory data source**: `filter_categories` template variable (provided by Nuvemshop on category pages) contains the direct child categories. This is confirmed by existing usage in `snipplets/grid/categories.tpl` and `templates/category.tpl`.
- **Dropdown is server-rendered navigation**: Unlike the product carousel dropdown (JS tab-switching), the category dropdown items are `<a>` links that navigate to the child category URL. No AJAX or SPA behavior. When the user selects a child category, a full page load occurs showing that child's page with its own children in the dropdown.
- **"Todos" link in dropdown**: Links to the current parent category URL (the category being viewed).
- **Product card reuse**: The newer Tailwind-based `item-card.tpl` will be adapted/used for the category grid rather than the legacy Bootstrap `item.tpl`. This may require adding features that `item-card.tpl` currently lacks (e.g., quickshop integration) or accepting a simpler card for now.
- **Mobile width `w-[393px]`**: The Figma spec uses a fixed 393px mobile frame width. This will be translated to responsive/fluid widths (not hardcoded) in actual implementation.
- **Mobile grid `w-[196.5px]`**: This is approximately 50% of 393px, confirming 2-column layout. Will be implemented as `w-1/2` or equivalent flex/grid.
- **Footer unchanged**: No modifications to footer snipplets or structure.
- **Header structure unchanged**: Only the initial `data-state` attribute value changes conditionally — no structural changes to `header-new.tpl`.
- **`category.description`**: The current page-header shows category description if present. The Figma designs do not show a description area, so it may be omitted or kept minimal.

## 3. Affected Architectural Domains

| Domain | Area | Reason |
|---|---|---|
| **Template Layer** | `templates/category.tpl` | Full rewrite from Bootstrap to Tailwind layout |
| **Template Layer** | `snipplets/header/header-new.tpl` | Conditional `data-state` initial value based on `template` variable |
| **Template Layer** | New breadcrumb snipplet or inline in category.tpl | New Tailwind breadcrumb component |
| **Template Layer** | `snipplets/grid/item-card.tpl` (potential) | May need grid-specific adaptations vs carousel-specific |
| **Template Layer** | New or adapted product grid snipplet | Grid wrapper for category (different column counts than carousel) |
| **JS Module Layer** | `__src/js/modules/category/` (NEW) | New module directory for category dropdown behavior (open/close, icon rotation) |
| **JS Module Layer** | `__src/js/index.js` | Register new category module import+invoke |
| **CSS Layer** | `__src/css/app.css` | Potentially new header state or category-specific styles if needed |
| **Snipplet Organization** | `snipplets/` | New domain folder or reuse of existing `grid/` for category-specific components |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S2, S3, L5, R1, R3, F4, F5, F6

## 5. Invariant Impact Explanation

- **A1**: New JS module for category dropdown MUST be created under `__src/js/modules/category/` (new context directory, permitted by A1's extension rule).
- **A2**: The new category dropdown module MUST guard with `if (!element) return;` checking for the category dropdown root DOM element.
- **A3**: The new module MUST be a named export, imported and invoked in `index.js`. No self-execution.
- **A5**: No cross-module communication expected for this feature. The dropdown is self-contained.
- **A6**: If the dropdown or any dynamic content inserts Lucide icons via innerHTML, `lucide.createIcons()` MUST be called after.
- **A8 / F4**: All colors in the new category page MUST use CSS custom properties or Tailwind `@theme` tokens. No hardcoded hex/rgba values.
- **A9**: The header `data-state` pattern is directly affected. The initial value must be set to `"active"` on non-home pages via template conditional.
- **A10**: Any new snipplets MUST be organized by domain folder and included via `{% snipplet %}` or `{% include %}`.
- **A14 / F5**: Any icons (filter icon, dropdown chevron, breadcrumb separator) MUST use Lucide `<i data-lucide="...">`. No new SVG snipplets.
- **D1**: The category dropdown reads data from template-rendered HTML (child category names, URLs via `data-*` attributes or `<a>` elements).
- **S3**: Dropdown open/close state should prefer `hidden` attribute or `data-state` pattern per the state mechanism hierarchy.
- **L5**: Vanilla JS only in the new module. No jQuery.
- **R1**: New module MUST NOT import from sibling modules.
- **R3**: New `js-*` class selectors created for the category dropdown MUST be documented as a binding contract.
- **F6**: No self-invoking module pattern.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- The feature involves a full template rewrite of `category.tpl` (moving from Bootstrap to Tailwind), which is a large surface area change.
- The header state change (`transparent` → `active` on non-home pages) affects all pages globally, not just the category page. This has broad visual impact and must be carefully scoped.
- The product card choice (`item-card.tpl` vs `item.tpl`) may create gaps — `item-card.tpl` lacks quickshop, installments, and other features that `item.tpl` has.
- No test infrastructure (Risk 6 from contract) means all validation is manual.
- The `filter_categories` variable behavior needs to be verified against Nuvemshop's actual API — the assumption is that it provides direct children only, but this is inferred from existing usage.

## 7. Likely Impacted Areas (Scoped)

| File / Area | Impact Type |
|---|---|
| `templates/category.tpl` | Full rewrite |
| `snipplets/header/header-new.tpl` | Conditional data-state change (1-2 lines) |
| `__src/js/modules/category/category-dropdown.js` | New file (dropdown open/close, icon rotation) |
| `__src/js/index.js` | Add import + invoke for new module |
| `snipplets/grid/item-card.tpl` | Potential adaptation for grid usage (may need `item_class` flexibility) |
| New breadcrumb snipplet (e.g., `snipplets/navigation/breadcrumb-new.tpl`) | New file — Tailwind breadcrumb |
| `__src/css/app.css` | Potential: new `data-state` for header colored initial state, or minimal additions |
| `snipplets/grid/pagination.tpl` | May need Tailwind restyling or wrapping |
| `layouts/layout.tpl` | Potential: page background color conditional |

## 8. Visual / Component Surface Impact

**From the Figma screenshots analysis:**

### Mobile (1st image):
- Header: Already new header, showing with **colored state** (romã logo in red, icons in dark color) — confirms header must NOT be transparent on category pages.
- Category header bar: `h-[76px]`, category name "Camisetas" as heading, "Regular" dropdown button with chevron, "Filtros" text link aligned right.
- Breadcrumb: Simple text trail — "Início / Camisetas / Regular" — with `/` as separator, left-aligned, small text.
- Product grid: 2 columns, each product card shows: image, cart icon button overlay at bottom-right of image, product name, price, and category label badges ("Regular", "Premium").
- The label badges on product cards appear to be variant/tag labels, styled as small bordered pills.
- Footer: Standard footer, untouched.

### Desktop/Medium (2nd image):
- Header: Colored state, full navigation bar visible with "Produtos —", "Sobre", "Suporte", "Personalize" nav items, plus "Buscar", "Login", "Carrinho(0)".
- Top promotional banner: "15% OFF em 3 itens ou mais" — this is the advertising bar, already part of the header.
- Category header bar: "Camisetas" heading, "Regular" dropdown, no visible "Filtros" link (may be hidden or positioned differently).
- Breadcrumb: "Calças / Jeans / Calça Jeans Baggy - Preto" (shows category hierarchy).
- Product grid: 3 columns per row (medium screens), product cards with: image (larger), a size/action button group ("P", chevron, "+") at bottom of image area, product name, price, and two badges ("Slim", "Canelado").
- The "P ^  +" buttons appear to be a quick-add variant selector (size selector + add to cart) — this is a new component not currently in `item-card.tpl`.
- Footer: Standard three-column layout, untouched.

### CSS Classes from Spec:
- Desktop category header: `flex h-[76px] items-center gap-2.5 self-stretch p-6`
- Desktop breadcrumb: `flex items-center self-stretch px-6 py-2`
- Desktop grid: `flex items-start content-start self-stretch flex-wrap`
- Mobile category header: `flex w-[393px] h-[76px] justify-between items-center p-6` (note: `w-[393px]` is Figma frame width, should be `w-full` in implementation)
- Mobile breadcrumb: `flex items-center self-stretch px-6 py-2`
- Mobile grid: `flex w-[196.5px] flex-col items-start` (note: `w-[196.5px]` is Figma per-item width ≈ 50%, should be flex-based)

## 9. Architectural Constraints Summary

1. **No jQuery in new JS modules** — the category dropdown module must be vanilla JS only (L5).
2. **Header state change must be template-level** — use `{% if template != 'home' %}data-state="active"{% else %}data-state="transparent"{% endif %}` in `header-new.tpl`. No JS changes needed for initial state (A9).
3. **Colors from theme tokens only** — all new colors must use `bg-bg`, `text-fg`, `text-secondary`, or CSS custom properties. No hex values (A8, F4).
4. **Icons via Lucide only** — the filter icon, dropdown chevron, breadcrumb separators must use `<i data-lucide="...">` (A14, F5).
5. **New JS module in new context dir** — `__src/js/modules/category/` is a valid new context directory per A1. Must follow the exact import/invoke pattern in `index.js` per A3.
6. **DOM binding contract** — all new `js-*` class selectors introduced for the category dropdown become part of the template-JS binding contract (R3) and must be stable.
7. **No cross-module imports** — the category dropdown module must not import from `product-carousel.js` even though they share similar dropdown patterns. Code similarity is acceptable; import dependency is not (R1, F9).
8. **Dropdown state management** — must use `hidden` attribute or `data-state` for open/close state per S3 preference hierarchy.
9. **Product card choice has trade-offs** — `item-card.tpl` (Tailwind) is preferred for consistency but currently lacks features visible in the Figma (size selector buttons, quickshop). This gap must be resolved during implementation.
10. **Page background** — changing the site background to white/cream for non-home pages could affect other pages (product, cart, etc.). Should be scoped carefully, possibly via a body class or template-level conditional.
