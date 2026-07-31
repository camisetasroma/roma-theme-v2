# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

A global toast notification system that supports multiple use cases (success messages, cart additions, errors, promotions). Toasts must be positioned below the header in the top-right corner, dynamically accounting for the header's variable height. The system must expose a simple API for triggering toasts from any module. The toast container uses a semi-transparent background with backdrop blur, 241x77px dimensions, rounded border, and theme-aware colors (no hardcoded values). The reference document `docs/searches/toast-system.md` points to `toastify-js` but NO toast system currently exists in the codebase — a previous implementation was fully deleted (see RISK 1 in architecture contract).

## 2. Assumptions (if any)

- **A-1**: The toast system will be a `system/` module (global, not page-specific) since toasts can be triggered from any page context.
- **A-2**: The toast API will be exposed via `window.*` globals (per S2) so that both custom modules and legacy `store.js.tpl` can trigger toasts.
- **A-3**: Toast positioning "below the header" means using the header element's dynamic `offsetHeight` or `getBoundingClientRect()` at render time, since the header is `position: fixed` with variable height (advertising bar may or may not be present, mobile vs desktop).
- **A-4**: The CSS classes provided in the spec contain hardcoded colors (`rgba(255,255,246,0.70)` for background and `#80807B` for border) — these MUST be replaced with CSS custom property equivalents per A8/F4 before implementation.
- **A-5**: Toasts will use the existing `--z-toast: 90` token already defined in the `@theme` block (currently orphaned).
- **A-6**: Multiple toasts may be visible simultaneously (stacked vertically), since the spec does not explicitly limit to a single toast.
- **A-7**: Toast dismissal mechanism is not specified — assumed auto-dismiss after timeout with optional manual close.
- **A-8**: The `toastify-js` reference in `docs/searches/toast-system.md` is a design reference only; the implementation will be vanilla JS per L5 (no jQuery, no external dependencies beyond what's vendored).

## 3. Affected Architectural Domains

- **JS Modules** (`__src/js/modules/system/`): New `toast.js` module
- **JS Entry Point** (`__src/js/index.js`): New import and invocation
- **CSS** (`__src/css/app.css`): Toast-specific styles (animations, positioning, state-driven visibility)
- **Templates** (`snipplets/`): Possible toast container markup in `layout.tpl` or a new snipplet
- **Cross-module communication** (`window.*`): New global API surface (e.g., `window.showToast()`)
- **Z-index layer** (`@theme`): Consumes existing `--z-toast: 90` token

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A12, A14, D1, S2, S3, S4, L5, R1, R3, F2, F4, F6, F9

## 5. Invariant Impact Explanation

- **A1**: The toast module MUST be created at `__src/js/modules/system/toast.js` — system context because it is global.
- **A2**: The module MUST guard execution with a root DOM element check (e.g., the toast container element).
- **A3**: Must export a named function, imported and called in `index.js`. No self-execution.
- **A5**: The toast API (`window.showToast()`, etc.) MUST be exposed via `window.*` to allow cross-module and legacy layer consumption.
- **A6**: If any toast content includes Lucide icons (e.g., a checkmark or error icon), `lucide.createIcons()` MUST be called after `innerHTML` insertion.
- **A8/F4**: The provided CSS classes contain `rgba(255,255,246,0.70)` and `#80807B` — these MUST be replaced with `var(--background-color)` / `var(--color-bg)` and `var(--text-color)` / `var(--color-secondary)` equivalents. Adding new hardcoded colors would violate the contract and worsen existing RISK 2.
- **A9**: Toast visibility state SHOULD use `data-state` attributes (e.g., `data-state="visible"` / `data-state="hidden"`) for CSS-driven enter/exit animations, consistent with header and search overlay patterns.
- **A12**: The toast module runs after Lucide and Swiper are available — no load order conflicts.
- **A14**: Any icons in toast markup MUST use `<i data-lucide="...">`, never SVG snipplets.
- **D1**: Toast JS reads positioning from the header DOM element (`offsetHeight`), which is the standard channel.
- **S2**: Global API must follow `window.fn = ...` (provider) / `window.fn?.()` (consumer) pattern.
- **S3**: UI state preference order: `hidden` attr for simple show/hide, `data-state` for animated transitions.
- **S4**: If "shown once" toast behavior is needed in the future, must use `localStorage` with `roma_` prefix.
- **L5**: Vanilla JS only. No jQuery.
- **R1/F9**: No imports from sibling modules. Communication via `window.*` only.
- **R3**: New `js-*` class selectors (e.g., `js-toast-container`) become binding contracts between templates and JS.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- The previous toast implementation was deleted due to header positioning conflicts (`position: fixed` header at `z-50` vs toast positioning). This is the core risk that must be solved correctly.
- The hardcoded colors in the provided CSS spec conflict with A8/F4 and must be substituted — failure to do so worsens RISK 2.
- RISK 1 (documentation drift) is already active — the deleted toast/modal references in `important-project-stufs.md` must NOT be used as implementation reference. The architecture contract is the source of truth.
- The `--z-toast: 90` token exists but has no consumer — confirming it is reserved for this feature, but also confirming that no toast infrastructure currently exists (clean slate).

## 7. Likely Impacted Areas (Scoped)

| Area | File(s) | Change Type |
|------|---------|-------------|
| JS Module | `__src/js/modules/system/toast.js` | NEW file |
| JS Entry | `__src/js/index.js` | Add import + invocation |
| CSS | `__src/css/app.css` | Add toast styles (animations, positioning, data-state selectors) |
| Template | `layouts/layout.tpl` or `snipplets/notification/toast.tpl` | Toast container markup |
| Cross-module | `window.showToast()` (minimum) | New global API |
| Z-index | `@theme` block `--z-toast: 90` | Consumed (no change needed, already defined) |

## 8. Visual / Component Surface Impact

- **Positioning**: Toast container must be `position: fixed`, anchored to top-right, with `top` value dynamically computed from the header's current height. The header is `position: fixed; top: 0; z-index: var(--z-50)` (z-index 50). The toast must use `z-index: var(--z-toast)` (90) to layer above the header.
- **Header interaction**: The header has dynamic height due to: (1) optional advertising bar, (2) responsive breakpoints (mobile vs desktop layout). Toast `top` offset must be recalculated on window resize and header state changes.
- **Previous failure context**: User reports that prior implementation caused header positioning bugs. The toast container MUST NOT interfere with the header's `position: fixed` or its `data-state` transitions. Using a separate `position: fixed` container with computed `top` (rather than nesting inside the header) avoids this conflict.
- **CSS classes from spec**: `flex w-[241px] h-[77px] justify-end items-start gap-2.5 border backdrop-blur-sm px-2 py-2.5 rounded-lg border-solid` — dimensions and layout are acceptable as Tailwind utilities. Background and border colors MUST use theme tokens.
- **Animations**: Enter/exit animations should use CSS transitions on `data-state` changes, consistent with A9 pattern.

## 9. Architectural Constraints Summary

1. Module at `__src/js/modules/system/toast.js`, named export, guarded, registered in `index.js` (A1, A2, A3, F6).
2. No hardcoded colors — replace `rgba(255,255,246,0.70)` and `#80807B` with CSS custom properties (A8, F4).
3. Toast API via `window.*` globals for cross-module access (A5, S2).
4. State management via `data-state` attributes with CSS selectors for animations (A9, S3).
5. Icons via Lucide only; call `lucide.createIcons()` after dynamic HTML insertion (A6, A14).
6. Use existing `--z-toast: 90` token for z-index layering (already in `@theme`).
7. Vanilla JS only — no jQuery, no external toast libraries (L5, F2).
8. Toast container positioned independently from header (`position: fixed` with computed `top`) to avoid the positioning conflict that caused the previous implementation to be deleted.
9. No horizontal module imports — if other modules need to trigger toasts, they use `window.showToast?.()` (R1, F9, S2).
10. Documentation in `important-project-stufs.md` referencing deleted toast system is STALE (RISK 1) — must not be used as implementation reference.
