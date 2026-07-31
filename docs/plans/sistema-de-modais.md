# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A14, S2, S3, S4, D1, F2, F4, F5, F6, F7, L5, R1, R3

### Invariant Tension Check

- **A9 vs S3**: No tension. `data-state` is the correct mechanism for a multi-state overlay component (open/closed). This aligns with both invariants — A9 mandates `data-state` for overlays, S3 ranks it as the preferred mechanism for state-driven components with CSS transitions.
- **R3 (legacy selectors)**: The legacy `snipplets/modal.tpl` uses `js-modal`, `js-modal-close`, `js-modal-overlay`. The new modal system MUST use a distinct prefix to avoid collisions. Chosen prefix: `js-gaius-modal-*` (consistent with the `gaius` bundle naming convention and clearly distinct from legacy selectors).
- **A5 (new globals)**: Adding `window.openModal()` and `window.closeModal()` extends the cross-module global surface. No tension — A5 explicitly permits this pattern and S2 defines the contract.
- **Orphaned z-index token**: `--z-modal: 100` already exists in `@theme` but has no consumer. Reusing it is correct and resolves the orphan.

### Risk Level
**MEDIUM**

Rationale:
- Scroll locking (`body overflow hidden`) can conflict with search overlay and header state if not carefully managed (must restore on close).
- Legacy modal selectors require distinct naming to avoid jQuery-based `store.js.tpl` interference.
- Previously deleted modal system (RISK 1 in architecture contract) means care must be taken to align with current patterns (toast system is the reference).

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

No data/services layer changes required. The modal system is purely client-side UI. No AJAX, no platform API calls, no template variables consumed.

### 2.2 State / Hooks

**NEW FILE**: `__src/js/modules/system/modal.js`

- Export named function `modalSystem` — constrained by **A3**, **F6**
- First statement: guard on `.js-gaius-modal-container` existence — constrained by **A2**
- Internal state via closure variables: `currentModal` (reference to active modal element or null) — constrained by **S1** (local state only)
- `data-state` attribute on `.js-gaius-modal-container`: `"closed"` (default) / `"open"` — constrained by **A9**, **S3**
- Global API exposure: `window.openModal = function({ title, content, size })` and `window.closeModal = function()` — constrained by **A5**, **S2**
- Scroll lock: set `document.body.style.overflow = "hidden"` on open, restore original value on close — constrained by **S3** (element.style is appropriate here since the value is computed/toggled at runtime)
- Close triggers: (1) close button click via `addEventListener` (not inline handler — **F7**), (2) backdrop/overlay click, (3) Escape key press
- After injecting modal content HTML via `innerHTML`, call `lucide.createIcons()` with `typeof lucide !== "undefined"` guard — constrained by **A6**, **A12**
- Only one modal at a time: calling `openModal()` while one is open closes the current one first (assumption A-3 from research)
- `escapeHtml` utility for any user-provided text content (matching toast pattern) — constrained by **F7** (security)

**MODIFY**: `__src/js/index.js`

- Add `import { modalSystem } from "./modules/system/modal";` in the System section
- Add `modalSystem();` invocation after `toastSystem();`
- Constrained by **A3**, **R1**

### 2.3 UI / Components

**NEW FILE**: `snipplets/notification/modal.tpl`

- Minimal container element: a single `<div>` with class `js-gaius-modal-container` and `data-state="closed"`
- Inline styles for fixed positioning, z-index via `var(--z-modal)`, full viewport coverage
- Contains two child zones rendered by JS: overlay backdrop and content wrapper
- Starts hidden via `data-state="closed"` CSS (opacity 0, pointer-events none)
- Constrained by **A10** (snipplet organization by domain — `notification/` folder), **R3** (new `js-*` class contract)

**MODIFY**: `layouts/layout.tpl`

- Add `{% snipplet "notification/modal.tpl" %}` adjacent to the existing toast snipplet include (line ~124 area)
- Constrained by **A10**

**New `js-*` class contracts** (constrained by **R3**):
- `.js-gaius-modal-container` — root container, carries `data-state`
- `.js-gaius-modal-overlay` — backdrop element (click to close)
- `.js-gaius-modal-content` — content wrapper (centered box)
- `.js-gaius-modal-close` — close button

### 2.4 Styling

**MODIFY**: `__src/css/app.css`

Add a new CSS block after the toast notification styles section. The block will contain:

1. `.js-gaius-modal-container[data-state="closed"]` — opacity 0, pointer-events none, visibility hidden
2. `.js-gaius-modal-container[data-state="open"]` — opacity 1, pointer-events auto, visibility visible
3. `.js-gaius-modal-container [data-state]` — transition definitions (opacity, transform) matching the toast pattern duration/easing
4. Overlay backdrop styles — semi-transparent background using `color-mix(in srgb, var(--primary-color) 40%, transparent)` or similar theme-derived value — constrained by **A8**, **F4**
5. Modal content box — background via `var(--background-color)`, text via `var(--primary-color)`, border-radius, shadow — constrained by **A8**, **F4**
6. Content entry animation — scale from 0.95 + fade in on `data-state="open"`, reverse on close
7. Close button positioning — absolute top-right within content box

No hardcoded hex/rgba values anywhere — all colors derived from CSS custom properties or `@theme` tokens.

### 2.5 Assets

No new assets required. The close button uses the Lucide `x` icon (already available via the vendored `lucide.min.js`) — constrained by **A14**, **F5**.

---

## 3. Execution Phases

### Phase 1: Template Foundation
1. Create `snipplets/notification/modal.tpl` with the container element
2. Modify `layouts/layout.tpl` to include the modal snipplet
3. Add CSS styles for the modal in `__src/css/app.css`

**Testable**: Build Tailwind CSS, load any page — the modal container should exist in DOM with `data-state="closed"` and be invisible.

### Phase 2: JS Module Implementation
1. Create `__src/js/modules/system/modal.js` with full modal logic
2. Modify `__src/js/index.js` to import and invoke `modalSystem`
3. Build JS bundle via esbuild

**Testable**: Open browser console, call `window.openModal({ title: "Test", content: "Hello" })` — modal should appear with fade/scale animation. Call `window.closeModal()` — modal should close. Test backdrop click, Escape key, close button, scroll lock.

### Phase 3: Integration Validation
1. Verify modal coexists with toast system (toast at z-90, modal at z-100)
2. Verify modal does not interfere with search overlay or header state
3. Verify scroll lock is properly restored after close
4. Verify Lucide icons render in modal content (close button)
5. Verify no legacy modal selector collisions

**Testable**: Open modal then trigger toast — toast should appear behind modal. Open search overlay, close it, open modal — no z-index conflicts. Open modal, close it — page scroll should be restored.

---

## 4. Risk Controls

### Edge Cases
- **Rapid open/close**: Calling `openModal()` immediately followed by `closeModal()` must not leave scroll locked or orphan elements
- **Double open**: Calling `openModal()` while a modal is already open must close the first before opening the second
- **Close when already closed**: `closeModal()` when no modal is open must be a no-op (no errors)
- **Body overflow restore**: If `body.style.overflow` was already set to something other than empty string before modal opened, that value must be preserved and restored on close (not blindly set to empty string)
- **Transition interruption**: Opening during a close transition (or vice versa) must handle gracefully — use `transitionend` listener with `{ once: true }` and a `setTimeout` fallback (matching toast pattern)
- **Empty content**: `openModal()` called with no content should either be a no-op or show an empty modal — not throw errors
- **Lucide not loaded**: Edge case where `lucide` global is undefined — the `typeof` guard prevents runtime errors

### Regression Zones
- **Search overlay** (`search.js`): Both use `data-state` and affect page interaction. Must ensure modal z-index (100) stacks above search overlay if both happen to be open.
- **Header animations** (`header.js`): Scroll-based header state changes must continue working while modal is open (scroll is locked on body, but header reads scroll position).
- **Toast system** (`toast.js`): Toast z-index (90) is below modal (100). Toasts should still be functional but appear behind the modal. No code changes to toast needed.
- **Legacy modal** (`snipplets/modal.tpl`, `store.js.tpl`): Legacy jQuery modal uses `js-modal`, `js-modal-close`, `js-modal-overlay` selectors. The new system uses `js-gaius-modal-*` prefix — no selector collision. However, if both a legacy modal and new modal are open simultaneously, z-index stacking must be verified.

### Strict Non-Modification Areas
- `static/js/store.js.tpl` — legacy jQuery code, must not be touched
- `static/js/external.js.tpl` — third-party libraries, must not be touched
- `snipplets/modal.tpl` — legacy modal template, must remain untouched
- `__src/js/modules/system/toast.js` — out of scope (toast border refinement is a separate concern per A-6 in research assumptions)
- `__src/js/modules/system/header.js` — no modifications needed
- `__src/js/modules/system/search.js` — no modifications needed
- `__src/js/modules/system/menu.js` — no modifications needed
- `config/settings.txt` — no new settings needed for the modal system (it is programmatic, not admin-configured)
- `esbuild.config.mjs` — no changes needed (existing config handles new modules automatically)
- `pre-build.js` — no changes needed
