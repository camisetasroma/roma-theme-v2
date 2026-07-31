# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Add a product sorting dropdown to the category page. The dropdown must allow users to reorder the product grid by: best-selling, price ascending, price descending, A-Z, Z-A, and newest-to-oldest. On desktop, the sorting dropdown sits to the left of the existing filter button in the title row. On mobile, the sorting dropdown drops below the breadcrumb, matching the filter button's mobile positioning pattern. The sorting mechanism must integrate with the Nuvemshop platform's native `sort_by` URL parameter system.

## 2. Assumptions (if any)

- **A1**: The existing `snipplets/grid/sort-by.tpl` renders a native `<select>` with class `js-sort-by`, which the Nuvemshop platform JS (`store.js.tpl`) already listens to for sort navigation. This platform behavior is assumed functional and will be leveraged rather than reimplemented.
- **A2**: The sort option labels in `sort-by.tpl` are hardcoded in Spanish. They will need translation via `| translate` or `| t` filter to match the store's language. The feature request labels (Portuguese) map to platform sort keys as follows: "Mais vendidos" → `best-selling`, "Menor preço ao Maior preço" → `price-ascending`, "Maior preço ao Menor preço" → `price-descending`, "A-Z" → `alpha-ascending`, "Z-A" → `alpha-descending`, "Mais novo ao mais antigo" → `created-descending`.
- **A3**: "Mais novo ao mais antigo" maps to `created-descending` (newest first). The platform also provides `created-ascending` (oldest first) which was not requested and should be omitted or included based on implementation decision.
- **A4**: The existing `sort-by.tpl` uses `{% embed "snipplets/forms/form-select.tpl" %}` which renders a native `<select>` element — not a custom styled dropdown matching the theme's visual language. The feature request describes a "dropdown" which could mean either the native select or a custom-styled dropdown matching `category-dropdown`'s visual pattern. Given the visual parity requirement ("ao lado esquerdo do botão de filtros"), a custom-styled dropdown is assumed to better match the existing category page design.
- **A5**: If a custom-styled dropdown is built instead of using the native `<select>`, the sorting navigation must be handled by either: (a) a hidden `<select class="js-sort-by">` that the platform JS listens to, or (b) direct URL navigation via `window.location` with the `sort_by` query parameter. Both approaches are valid LS integrations.
- **A6**: The existing `category-dropdown.js` module uses `document.querySelector(".js-category-dropdown")` which only supports a single dropdown instance. A sorting dropdown would need either a separate module or a refactored shared module.

## 3. Affected Architectural Domains

| Domain | Impact |
|---|---|
| **Template Layer** | `templates/category.tpl` — add sorting dropdown markup (desktop + mobile instances) |
| **Snipplet Layer** | `snipplets/grid/sort-by.tpl` — may be reused, adapted, or replaced depending on approach |
| **JS Module Layer** | `__src/js/modules/category/` — new module or extension for sorting dropdown interaction |
| **JS Entry Point** | `__src/js/index.js` — import and invoke new/modified category module |
| **CSS Layer** | `__src/css/app.css` — potential styling for sorting dropdown if custom-styled |
| **Build Output** | `static/js/gaius-v*.js` and `static/css/app.tpl` — rebuilt automatically |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S3, L5, R1, R3, F2, F4, F5, F6

## 5. Invariant Impact Explanation

- **A1**: New JS for sorting dropdown must live in `__src/js/modules/category/`. Cannot be written in `static/`.
- **A2**: The new module must guard execution with a root DOM element check (`if (!element) return;`) as first statement.
- **A3**: Must be a named export, imported and invoked in `index.js` under the `//Category` group. No self-execution.
- **A5**: If the sorting dropdown needs to communicate with other modules (unlikely), it must use `window.*` globals. For this feature, the dropdown is likely self-contained and stateless (delegates to platform navigation), so no new `window.*` globals are expected.
- **A6**: If the dropdown HTML uses Lucide icons (e.g., chevron-down), and the HTML is dynamically injected, `lucide.createIcons()` must be called after insertion.
- **A8**: No hardcoded theme-dependent colors in the dropdown styling. Must use Tailwind tokens or CSS custom properties.
- **A9**: If the dropdown uses a multi-state pattern (open/closed with CSS transitions), `data-state` is the preferred mechanism. However, the existing `category-dropdown.js` uses `hidden` attribute + `aria-expanded`, which is also acceptable per S3 for binary toggle controls.
- **A10**: Any new snipplet must be organized in the appropriate domain folder (`snipplets/grid/` or `snipplets/navigation/`).
- **A12**: The gaius bundle loads after platform JS. This means the platform's `.js-sort-by` change handler will already be bound. If using a hidden `<select>` approach, the select must exist in the initial HTML (template-rendered), not dynamically created.
- **A14**: Icons must use Lucide `<i data-lucide="...">`. The existing `form-select.tpl` uses an SVG snipplet (`snipplets/svg/chevron-down.tpl`) — if this template is reused, the SVG should be replaced with Lucide per the migration mandate.
- **D1**: JS reads sort state from DOM (e.g., `data-*` attributes or the current URL's `sort_by` param). JS must not call `LS.*` directly.
- **S3**: UI state preference order: `hidden` attr > `data-state` > `aria-expanded` > classList > element.style.
- **L5**: Vanilla JS only. No jQuery.
- **R1**: No horizontal imports between sibling modules.
- **R3**: New `js-*` class selectors become binding contracts between template and JS. Must be documented.
- **F2, F4, F5, F6**: Standard forbidden patterns apply.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**LOW**

Rationale: The Nuvemshop platform already provides the sorting mechanism (`sort_methods`, `sort_by` template variables, and `js-sort-by` change handler in `store.js.tpl`). The feature is primarily a UI/template task with minimal custom JS. The `category-dropdown.js` provides a proven pattern to follow. No new cross-module communication is needed. Infinite scroll already preserves `sort_by` in `pages.next` URL, so no compatibility issue. The only moderate concern is the LS integration approach — whether to use the native `<select class="js-sort-by">` (simplest, guaranteed platform compatibility) or a custom dropdown with manual URL navigation (more design control, slightly higher implementation surface).

## 7. Likely Impacted Areas (Scoped)

| File | Change Type |
|---|---|
| `templates/category.tpl` | Edit — add sorting dropdown markup in two locations (desktop row + mobile below breadcrumb) |
| `snipplets/grid/sort-by.tpl` | Edit or replace — adapt for custom dropdown pattern, update translations, fix SVG→Lucide |
| `__src/js/modules/category/category-sorting.js` (new) | Create — new module for sorting dropdown toggle and sort selection behavior |
| `__src/js/index.js` | Edit — add import and invocation of new category sorting module |
| `__src/css/app.css` | Possibly edit — add dropdown styling if needed beyond Tailwind utilities |
| `snipplets/forms/form-select.tpl` | No change if custom dropdown; minor edit if reusing (SVG→Lucide per A14) |

## 8. Visual / Component Surface Impact

- **Desktop**: New dropdown element appears to the LEFT of the existing filter button in the `flex items-center gap-3 mb-2` title row. Layout impact is minimal — it joins the existing flex flow alongside `<h1>`, category dropdown, and filter button.
- **Mobile**: New dropdown element appears BELOW the breadcrumb, matching the mobile filter button's positioning pattern (`flex md:hidden`, with `mt-2`). This means on mobile there will be two action elements below the breadcrumb: the sorting dropdown and the filter button. Their relative order and layout (side-by-side or stacked) needs to be defined.
- **Dropdown panel**: When open, displays a list of sort options. Visual style should match the existing `category-dropdown` pattern (positioned absolute, bg-bg, border, shadow).
- **Active state**: The currently selected sort option should be visually indicated (e.g., bold, checkmark icon, or different color).
- **Icon**: Likely uses a chevron-down Lucide icon for the trigger, consistent with the existing category dropdown.

## 9. Architectural Constraints Summary

1. **JS must live in `__src/js/modules/category/`** — a new module file (e.g., `category-sorting.js`) following A1, A2, A3, F6 patterns.
2. **No jQuery** — vanilla JS only (L5, F2).
3. **No hardcoded colors** — use Tailwind tokens or CSS custom properties (A8, F4).
4. **Icons must use Lucide** — if a chevron icon is needed, use `<i data-lucide="chevron-down">`, not SVG snipplets (A14, F5).
5. **LS integration must go through the platform** — either via a hidden `<select class="js-sort-by">` that the platform's `store.js.tpl` already handles, or via direct URL navigation with `?sort_by=` parameter. Custom JS must NOT call `LS.*` directly (D1, L6).
6. **DOM binding contract** — new `js-*` class selectors must be established and documented (R3).
7. **Module isolation** — no imports from sibling modules; stateless or closure-scoped state only (R1, S1).
8. **Build pipeline** — changes to `__src/` require rebuild via esbuild and Tailwind CLI. No manual edits to `static/` (A4, F1).
