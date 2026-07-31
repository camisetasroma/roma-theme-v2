# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A12, A14, D1, S2, S3, S4, L5, R1, R3, F2, F4, F6, F9

### Invariant Tension Check
- **A8/F4 vs spec CSS**: The provided visual spec contains `rgba(255,255,246,0.70)` for background and `#80807B` for border. These MUST be replaced with CSS custom property equivalents. No tension — invariant overrides spec.
- **A9 vs toast lifecycle**: `data-state` is designed for overlay components (header, search). Toasts are transient notifications, not overlays. However, the pattern fits well for enter/exit animation states (`data-state="entering"`, `data-state="visible"`, `data-state="exiting"`). No real tension — `data-state` applies naturally.
- **A2 vs toast container**: The module must guard on its root DOM element. The toast container will be rendered in `layout.tpl`, guaranteeing it exists on every page. The guard remains mandatory per A2 even though the element will always exist.
- No invariant violations detected. Plan proceeds.

### Risk Level
**MEDIUM**
- Previous toast implementation was deleted due to header positioning conflicts
- Hardcoded colors in spec must be substituted
- RISK 1 (documentation drift) means stale references exist — must not be consulted

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
No data layer changes required. Toasts are purely client-side UI with no server interaction. Toast content is provided at call time by the triggering module or legacy layer.

### 2.2 State / Hooks

**CREATE**: `__src/js/modules/system/toast.js`
- Named export: `export const toastSystem = () => { ... }`
- DOM guard: `const container = document.querySelector(".js-toast-container"); if (!container) return;` (A2)
- Internal state (closure variables): `activeToasts` array tracking currently displayed toasts
- Global API exposed via `window.*` (A5, S2):
  - `window.showToast = function({ message, icon, duration }) { ... }` — creates and displays a toast
  - `window.closeToast = function(toastElement) { ... }` — manually dismisses a specific toast
  - `window.closeAllToasts = function() { ... }` — dismisses all active toasts
- Each toast element uses `data-state` attribute for animation lifecycle (A9): `"entering"` → `"visible"` → `"exiting"` → removed from DOM
- Auto-dismiss via `setTimeout` with configurable `duration` (default ~4000ms)
- Toast stacking: each new toast is appended to the container; vertical stacking handled by CSS `flex-direction: column` with `gap`
- Header height detection: read `.js-new-header` element's `offsetHeight` at toast creation time to set container `top` position (D1). Update on `resize` event.

**MODIFY**: `__src/js/index.js`
- Add import: `import { toastSystem } from "./modules/system/toast";`
- Add invocation: `toastSystem();`
- Place in the System section, after `searchSystem()` (A3)
- Why: Required by A3 — all modules must be imported and invoked from `index.js`
- Constrained by: A3, F6

### 2.3 UI / Components

**CREATE**: `snipplets/notification/toast.tpl`
- Toast container markup: a fixed-position wrapper with class `js-toast-container`
- The container is empty by default — toast elements are injected dynamically by JS
- Container attributes: `js-toast-container` class (R3 binding contract), positioned via CSS
- Why: Provides the DOM anchor point that the JS module guards on (A2) and manipulates
- Constrained by: A10 (snipplet organized by domain folder), R3 (js-* class binding)

**MODIFY**: `layouts/layout.tpl`
- Add `{% snipplet "notification/toast.tpl" %}` include, placed after the header snipplet but before `{% template_content %}`
- Why: Toast container must exist on every page, outside of page-specific templates
- Constrained by: A10

**Toast element structure** (created dynamically by JS):
- Each toast is a `div` with `data-state` attribute for animation states
- Contains: optional Lucide icon (`<i data-lucide="...">`) + message text + close button (`<i data-lucide="x">`)
- After `innerHTML` insertion, `lucide.createIcons()` MUST be called (A6)
- Icons use Lucide exclusively (A14)
- Close button triggers `window.closeToast?.()` on click

### 2.4 Styling

**MODIFY**: `__src/css/app.css`
- Add toast-specific CSS rules after the search overlay styles section
- Toast container: `position: fixed`, `right` aligned, `z-index: var(--z-toast)`, `display: flex`, `flex-direction: column`, `gap`, `pointer-events: none` (container itself doesn't block clicks)
- Individual toast: `pointer-events: auto`, dimensions from spec (`w-[241px]`, `h-[77px]` as Tailwind classes on the element, not in CSS), `backdrop-filter: blur(...)`, rounded border
- **Colors** (replacing spec hardcodes per A8/F4):
  - Background: `color-mix(in srgb, var(--background-color) 70%, transparent)` or equivalent using `var(--color-bg)` with opacity — MUST NOT use `rgba(255,255,246,0.70)`
  - Border: `var(--color-fg-muted)` or `var(--color-secondary)` — MUST NOT use `#80807B`
- `data-state` animation selectors (A9):
  - `.js-toast-container [data-state="entering"]`: transform from `translateX(100%)` to `translateX(0)`, opacity 0 → 1
  - `.js-toast-container [data-state="visible"]`: fully visible, stable position
  - `.js-toast-container [data-state="exiting"]`: opacity 1 → 0, transform slide out or fade
- CSS transitions on `opacity` and `transform` properties
- Why: Animations driven by CSS on `data-state` changes, consistent with header/search patterns
- Constrained by: A8, A9, F4, S3

### 2.5 Assets
No new assets required. Icons provided by Lucide (already vendored). No images or fonts needed.

---

## 3. Execution Phases

### Phase 1: Foundation (Template + CSS)
1. Create `snipplets/notification/toast.tpl` with the toast container markup (empty `div.js-toast-container`)
2. Add the snipplet include to `layouts/layout.tpl`
3. Add toast CSS rules to `__src/css/app.css` (container positioning, data-state animation selectors, theme-aware colors)
4. **Testable**: Container element visible in DOM inspector on any page. CSS rules compile without errors via Tailwind CLI.

### Phase 2: JS Module + Global API
1. Create `__src/js/modules/system/toast.js` with:
   - Named export `toastSystem`
   - DOM guard on `.js-toast-container`
   - Header height detection and resize listener
   - Toast creation logic (dynamic HTML with `data-state` lifecycle)
   - `lucide.createIcons()` call after icon insertion
   - Auto-dismiss timer
   - `window.showToast`, `window.closeToast`, `window.closeAllToasts` globals
2. Register in `__src/js/index.js` (import + invocation)
3. **Testable**: Call `window.showToast({ message: "Test", icon: "check" })` from browser console. Toast appears below header, animates in, auto-dismisses. Multiple toasts stack correctly. `window.closeAllToasts()` clears all.

### Phase 3: Validation + Resilience
1. Verify toast positioning across header states: `data-state="transparent"` and `data-state="active"`
2. Verify toast positioning with and without advertising bar
3. Verify resize behavior (header height recalculation)
4. Verify no interference with header `position: fixed` or header `data-state` transitions
5. Verify z-index layering: toast (90) renders above header (50) and below any future modal layer
6. Verify all colors use CSS custom properties (zero hardcoded values)
7. **Testable**: Manual browser testing across viewport sizes and header states

---

## 4. Risk Controls

### Edge Cases
- **Header not present**: If `.js-new-header` does not exist (edge case), toast container `top` should fall back to `0`
- **Rapid toast creation**: Multiple `showToast()` calls in quick succession must stack correctly without layout thrashing
- **Toast dismissed during animation**: If `closeToast()` is called while a toast is still in `"entering"` state, it should transition to `"exiting"` cleanly
- **Resize during active toasts**: Window resize must update container `top` for all currently visible toasts
- **Empty message**: `showToast()` with no message or empty string should be a no-op (guard clause)
- **Icon not in Lucide**: If an invalid `icon` name is passed, `lucide.createIcons()` will silently skip it — acceptable degradation

### Regression Zones
- **Header positioning**: The previous toast implementation was deleted because it interfered with the header. The toast container MUST be a separate `position: fixed` element, NOT nested inside the header. Monitor `.js-new-header` `data-state` transitions for any disruption.
- **Search overlay**: The search overlay uses `z-index` and `pointer-events` toggling. Toast at `z-90` must not block search overlay interaction when search is `data-state="open"`.
- **Existing `window.*` globals**: Currently only `window.setHeaderMenuActive` exists. Adding `window.showToast`, `window.closeToast`, `window.closeAllToasts` must not collide with any platform globals. Verify no `LS.showToast` or similar exists.

### Strict Non-Modification Areas
- `__src/js/modules/system/header.js` — must NOT be modified
- `__src/js/modules/system/menu.js` — must NOT be modified
- `__src/js/modules/system/search.js` — must NOT be modified
- `__src/js/modules/home/*` — must NOT be modified
- `static/js/store.js.tpl` — must NOT be modified
- `static/js/external.js.tpl` — must NOT be modified
- `config/settings.txt` — no new settings needed for toast system (toast is API-driven, not admin-configured)
- `@theme` block `--z-toast: 90` — already defined, must NOT be changed
