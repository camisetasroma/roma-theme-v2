# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Replace the broken legacy filter system on the category page with a clean implementation. The "Filtrar" button must be placed inside the category header container, aligned to the right. On desktop, clicking it opens a centered modal (using the new gaius modal system). On mobile, clicking it opens a drawer/sheet that slides in. The filter content (sorting, size, color, price range) must continue to dynamically render only the options available for the currently displayed products. The current applied-filter chips display must remain unchanged. The image reference shows a mobile drawer with: header ("Filtros" + close icon), breadcrumb, sort options as pill chips, size pills, color pills with color dots, and a price range section with "de/até" inputs and "Aplicar" button, plus a sticky "Filtrar" CTA at the bottom.

## 2. Assumptions (if any)

- **A1**: The legacy modal system (`snipplets/modal.tpl` with jQuery-driven `.js-modal-open` / `.modal-show` logic from `store.js.tpl`) is the broken part. It will be replaced for this use case.
- **A2**: The filter application logic (URL manipulation via `LS.urlAddParam`, `LS.urlRemoveParam`, `LS.urlRemoveAllParams` in `store.js.tpl`) will remain untouched — only the UI container/trigger changes.
- **A3**: "Drawer" on mobile means a full-height panel sliding from the right or bottom, distinct from the centered desktop modal. This requires a new presentation mode not currently supported by the gaius modal system (`modal.js`), which only renders centered modals.
- **A4**: The current applied-filter chips already rendered directly in `category.tpl` (lines 104-119) with `js-remove-filter` and `js-remove-all-filters` classes are satisfactory and must not change.
- **A5**: The breadcrumb shown inside the filter drawer (per the image) is a secondary breadcrumb specific to the filter panel context, not the page-level breadcrumb.
- **A6**: The filter content (sorting, sizes, colors, price) rendered inside the modal/drawer will continue to use the Nuvemshop platform's `product_filters` variable and `filter_categories`, preserving the dynamic "only available options" behavior.
- **A7**: The "Filtrar" button at the bottom of the mobile drawer (per image) likely triggers modal close (applying already-selected filters via URL), not a separate submit action — since filters are applied individually via `js-apply-filter` click handlers in `store.js.tpl`.
- **A8**: The feature spec says "modal on desktop, drawer on mobile" — this implies two distinct presentation modes for the same filter content, requiring either a dual-mode component or responsive CSS-driven layout switching.

## 3. Affected Architectural Domains

| Domain | Files/Areas |
|--------|-------------|
| **Template Layer** | `templates/category.tpl` (lines 95-141 — filter trigger, applied chips, legacy modal embed) |
| **Template Layer** | `snipplets/modal.tpl` (currently embedded for `nav-filters` — will be removed from this usage) |
| **Template Layer** | `snipplets/grid/filters.tpl` (filter checkboxes — content will be relocated into new container) |
| **Template Layer** | `snipplets/grid/categories.tpl` (subcategory list inside filter — content relocated) |
| **Template Layer** | `snipplets/notification/modal.tpl` (gaius modal container — may need structural extension) |
| **JS Module Layer** | `__src/js/modules/system/modal.js` (gaius modal — needs extension for drawer mode OR new module) |
| **JS Module Layer** | New module likely needed under `__src/js/modules/category/` for category filter UI |
| **CSS Layer** | `__src/css/app.css` (new styles for drawer component, responsive behavior) |
| **CSS Layer** | `static/css/style-async.scss.tpl` (existing `.filters-overlay`, `.modal-docked-small` styles — legacy, may become dead code) |
| **Legacy JS** | `static/js/store.js.tpl` (filter click handlers for `js-apply-filter`, `js-remove-filter` — must remain functional) |
| **Config** | `config/translations.txt` (if new translatable strings are needed) |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A14, D1, D2, S2, S3, L5, R1, R3, F2, F4, F5, F6

## 5. Invariant Impact Explanation

- **A1**: Any new JS for filter UI must live in `__src/js/modules/` — likely `modules/category/` (existing context) or `modules/system/` (if extending modal system).
- **A2**: New module must guard with DOM element existence check as first statement.
- **A3**: New module must be a named export, imported and invoked in `index.js`. No self-executing imports.
- **A5**: If the filter module communicates with the modal system, it must use `window.*` globals (e.g., `window.openModal`). No direct import from `modal.js`.
- **A6**: After injecting filter HTML containing Lucide icons, must call `lucide.createIcons()`.
- **A8**: All colors in new CSS/HTML must use CSS custom properties or `@theme` tokens. The reference HTML contains hardcoded Tailwind color classes (`text-red-950`, `bg-black`, `bg-white`, `bg-orange-100`, `bg-zinc-500`, `bg-green-700`, `text-neutral-500`) — these must be mapped to theme tokens or use platform CSS variables. Exception: color swatches using inline `style="background-color: {{ value.color_hexa }}"` from platform data are acceptable.
- **A9**: The drawer/modal state must use `data-state` attributes (`open`/`closed`) with CSS-driven transitions. This is the mandated pattern for overlay components.
- **A10**: New snipplets must be organized by domain folder (likely `snipplets/grid/` or a new `snipplets/filters/` folder).
- **A14**: All icons must use Lucide (`<i data-lucide="...">`). The spec requests a Lucide icon for filters — `sliders-horizontal` is already used in the current template; alternatives: `filter`, `list-filter`, `settings-2`.
- **D1**: JS must read filter data from DOM (data-* attributes rendered by templates). No direct platform API calls.
- **D2**: Filter AJAX logic stays in `store.js.tpl`. Custom JS must not duplicate `LS.urlAddParam`/`LS.urlRemoveParam` calls.
- **S2**: If a new cross-module signal is needed (e.g., filter module calling modal open), it must use `window.*` function pattern.
- **S3**: Drawer visibility state must prefer `data-state` attribute (mechanism 2) over classList toggles.
- **L5**: No jQuery in custom modules. The `js-apply-filter` / `js-remove-filter` click handlers in `store.js.tpl` are jQuery-based and must remain untouched.
- **R1**: No horizontal imports between modules.
- **R3**: Any new `js-*` classes become binding contracts between templates and JS.
- **F2**: No jQuery in `__src/js/`.
- **F4**: No hardcoded color values.
- **F5**: No new SVG snipplets. Use Lucide.
- **F6**: No self-invoking modules.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- The feature replaces a legacy jQuery modal system with the modern gaius modal system for a specific use case, which is architecturally aligned. However:
- The gaius modal (`modal.js`) currently only supports centered modals — it does not support drawer/sheet presentation. Extending it or creating a parallel drawer component introduces new architectural surface.
- The filter application logic lives in `store.js.tpl` (jQuery) and binds to `.js-apply-filter` / `.js-remove-filter` classes via jQuery delegation. The new container must ensure these jQuery handlers still fire correctly after the HTML is relocated.
- Two presentation modes (desktop modal vs mobile drawer) for the same content require careful responsive handling without duplicating DOM.
- Risk of breaking existing filter URL-based state management if DOM structure changes too aggressively.

## 7. Likely Impacted Areas (Scoped)

1. **`templates/category.tpl`** — Remove legacy `{% embed "snipplets/modal.tpl" %}` block (lines 121-139). Restructure filter trigger button placement within header. Filter content moves to new container.
2. **`__src/js/modules/system/modal.js`** — Potentially extend to support drawer mode, OR keep as-is and create a separate drawer component.
3. **`__src/js/modules/category/`** — New module for filter panel open/close behavior, responsive mode detection.
4. **`__src/js/index.js`** — Add import and invocation for new module.
5. **`__src/css/app.css`** — New CSS for drawer component (slide-in animation, responsive breakpoint switching between modal and drawer).
6. **`snipplets/grid/filters.tpl`** — Content may need restructuring to match the new chip-based pill UI shown in the image (currently uses checkbox inputs).
7. **`snipplets/notification/modal.tpl`** — Possibly unchanged if drawer is a separate component, or extended if drawer shares the gaius modal container.

## 8. Visual / Component Surface Impact

| Component | Impact |
|-----------|--------|
| **Category header bar** | Filter button moves into the title row (right-aligned), alongside category name and dropdown. Currently it's below the breadcrumb in a separate `div`. |
| **Filter trigger button** | Icon may change (from `sliders-horizontal` to another Lucide icon per spec). Button styling stays consistent with category dropdown pill style. |
| **Filter panel (mobile)** | Full-screen drawer sliding from right/bottom. Contains: header with title + close, breadcrumb, sort pills, size pills, color pills with swatches, price range inputs, sticky "Filtrar" CTA. |
| **Filter panel (desktop)** | Centered modal with same content. May omit sticky CTA if filters apply immediately. |
| **Applied filter chips** | No change. Current implementation in `category.tpl` lines 104-119 is satisfactory per spec. |
| **Filter content UI** | Major visual change: current checkbox-list style → pill/chip toggle style (per reference image). Sorting options become inline pill chips instead of checkboxes. |
| **Filters overlay** | Loading overlay (`js-filters-overlay`) must continue working during filter application. |

## 9. Architectural Constraints Summary

1. **No jQuery in custom JS** — The new filter panel module must be vanilla JS. Filter application logic stays in `store.js.tpl`.
2. **State via `data-state`** — The drawer/modal component must use `data-state="open"` / `data-state="closed"` for visibility, with CSS-driven transitions.
3. **Lucide icons only** — No new SVG snipplets. Use `<i data-lucide="...">` and call `lucide.createIcons()` after dynamic HTML insertion.
4. **No hardcoded colors** — All new styles must use `@theme` tokens or CSS custom properties. The reference HTML's `text-red-950`, `bg-black/5`, etc. must be translated to theme-aware equivalents (`text-secondary`, `bg-bg-subtle`, etc.).
5. **Module registration** — New module must follow `export const name = () => { ... }` pattern, imported as named export in `index.js`.
6. **DOM element guard** — New module must check root element existence as first statement.
7. **Cross-module via `window.*`** — If filter module needs to interact with modal system, use `window.openModal()` / `window.closeModal()`. No sibling imports.
8. **Legacy handler compatibility** — The jQuery event delegation for `js-apply-filter` and `js-remove-filter` in `store.js.tpl` must remain functional. The new DOM structure must preserve these class names and `data-filter-name`/`data-filter-value` attributes.
9. **Platform filter data** — Filter options must continue using `{{ product_filters }}` and `{{ filter_categories }}` template variables. No client-side AJAX for filter data.
10. **Responsive dual-mode** — Desktop (modal) and mobile (drawer) must be achieved via CSS media queries or JS viewport detection, not by duplicating DOM content.
