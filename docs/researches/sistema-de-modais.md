# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Implement a modal system for the Roma Theme V2. The modal must:
- Display content in a centered overlay on screen
- Include a close button (Lucide icon)
- Lock page scroll when open (`overflow: hidden` on `body`)
- Close when clicking outside the modal content (backdrop click)
- Appear and disappear with smooth transitions (fade/scale)
- Be easily invocable via a global API (`window.openModal()` / `window.closeModal()`)

The toast system already exists and is functional. The toast container background style (using `color-mix` with `--background-color`) may serve as a visual reference for the modal background. The toast border style (`1px solid var(--color-fg-muted)`) is explicitly noted as incorrect and should NOT be replicated — the modal should use a subtler border or no border.

A legacy `snipplets/modal.tpl` exists (jQuery-dependent, uses `store.js.tpl` classes like `js-modal`, `js-modal-close`, `js-modal-overlay` with `display:none` toggling). This legacy modal is NOT part of the custom JS layer and MUST NOT be extended. The new modal system must be built from scratch in `__src/js/modules/system/` following the same patterns as the toast system.

## 2. Assumptions (if any)

- **A-1**: The modal will be a **system-level** module (loaded on every page), similar to toast, since modals may be needed on any page.
- **A-2**: The modal will be opened programmatically via `window.openModal()` (not via template-rendered elements with pre-existing content). Content will be passed as HTML string or configuration object.
- **A-3**: Only one modal should be visible at a time. Opening a new modal closes the previous one.
- **A-4**: The legacy `snipplets/modal.tpl` and its jQuery-based logic in `store.js.tpl` will remain untouched. The new system is independent.
- **A-5**: The close button will use a Lucide icon (`x`), consistent with the toast close button.
- **A-6**: The "less attention-grabbing border" for toasts mentioned in the feature request is a secondary concern — it is a toast refinement, not part of the modal system scope. However, since the user explicitly mentioned fixing toast borders, this may be bundled.
- **A-7**: The modal backdrop will be a semi-transparent overlay, not a blur effect.

## 3. Affected Architectural Domains

| Domain | Impact |
|--------|--------|
| `__src/js/modules/system/` | New module: `modal.js` |
| `__src/js/index.js` | New import + invocation of `modalSystem` |
| `__src/css/app.css` | New CSS block for modal transitions and `data-state` styling |
| `snipplets/notification/` | New template: `modal.tpl` (container element for JS to mount into) |
| `layouts/layout.tpl` | Include the modal container snipplet (similar to toast container) |
| `window.*` globals | New globals: `window.openModal()`, `window.closeModal()` |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A12, A14, S2, S3, S4, D1, F2, F4, F5, F6, F7, L5, R1, R3

## 5. Invariant Impact Explanation

| Invariant | Impact |
|-----------|--------|
| **A1** | New module MUST be placed in `__src/js/modules/system/modal.js`. |
| **A2** | `modalSystem()` MUST guard on existence of root DOM element (`.js-modal-container`) as first statement. |
| **A3** | Module MUST export named function `modalSystem`. `index.js` MUST import and invoke it. No self-execution. |
| **A5** | `window.openModal()` and `window.closeModal()` become new cross-module globals. Must be documented in contract. |
| **A6** | If modal content contains Lucide icons (`<i data-lucide="...">`), `lucide.createIcons()` MUST be called after innerHTML injection. The close button icon requires this. |
| **A8** | No hardcoded colors. Backdrop, background, border, text — all MUST use CSS custom properties or `@theme` tokens. |
| **A9** | Modal overlay state MUST use `data-state` attribute pattern (e.g., `data-state="open"` / `data-state="closed"`). |
| **A12** | Module loads after Lucide. Can safely call `lucide.createIcons()` directly (or with `typeof` guard for safety). |
| **A14** | Close button icon MUST use Lucide `<i data-lucide="x">`. No SVG snipplet. |
| **S2** | `window.openModal` and `window.closeModal` MUST follow the provider/consumer pattern with optional chaining on consumer side. |
| **S3** | UI state preference order: `data-state` for the modal component state, `hidden` attribute not suitable here (needs transition support). Body scroll lock via `document.body.style.overflow = "hidden"`. |
| **F2** | Zero jQuery. Vanilla JS only. |
| **F4** | No hardcoded hex/rgba values in modal CSS or JS. |
| **F6** | No self-invoking module. Named export only. |
| **F7** | No inline event handlers in generated HTML. Use `addEventListener` after DOM insertion. |
| **L5** | Vanilla JS only in `__src/js/`. |
| **R1** | No horizontal imports. Modal module MUST NOT import from toast or any sibling. |
| **R3** | New `js-*` class contracts: `.js-modal-container`, `.js-modal-overlay`, `.js-modal-content`, `.js-modal-close`. These become binding contracts between template and JS. |

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Rationale:
- A modal system previously existed and was deleted (RISK 1 in architecture contract). Re-introducing it requires careful alignment to avoid repeating whatever caused its removal.
- Scroll locking interacts with the header system (`data-state` on `.js-new-header`) and the search overlay — must ensure no z-index or scroll conflicts.
- The `--z-modal: 100` token already exists in `@theme` but is currently orphaned. Reusing it is correct but confirms this was previously attempted.
- The legacy `snipplets/modal.tpl` and jQuery modal logic in `store.js.tpl` could create naming collisions if `js-modal` class prefix is reused. The new system MUST use distinct selectors (e.g., `.js-modal-system-*` or `.js-gaius-modal-*`).

## 7. Likely Impacted Areas (Scoped)

| Area | File(s) | Change Type |
|------|---------|-------------|
| JS Module | `__src/js/modules/system/modal.js` | **NEW FILE** |
| JS Entry | `__src/js/index.js` | Import + invocation |
| CSS | `__src/css/app.css` | New style block for modal `data-state` transitions |
| Template | `snipplets/notification/modal.tpl` (or similar) | **NEW FILE** — modal container element |
| Layout | `layouts/layout.tpl` | Include modal container snipplet |
| Toast (optional) | `__src/js/modules/system/toast.js` | Border style fix (if bundled per user request) |

## 8. Visual / Component Surface Impact

- **Overlay**: Full-screen semi-transparent backdrop at `z-index: var(--z-modal)` (100). Must sit above toast (90) and header.
- **Modal content**: Centered box. Background uses theme colors (`var(--background-color)` or `color-mix` variant). No hardcoded colors.
- **Close button**: Top-right corner of modal content, using Lucide `x` icon.
- **Transitions**: Backdrop fades in/out. Modal content scales/fades in/out. Uses `data-state` driven CSS transitions (pattern from toast and search overlay).
- **Scroll lock**: `body` overflow hidden when modal is open. Must be restored on close.
- **No header impact**: Modal z-index (100) > header z-index. Modal does not modify header state.
- **Toast coexistence**: Toasts at z-index 90 will appear behind the modal overlay. This is correct behavior — modal should take full attention.

## 9. Architectural Constraints Summary

1. New module at `__src/js/modules/system/modal.js` — named export `modalSystem`, guarded by container element check.
2. Container template in `snipplets/notification/` — minimal HTML container for JS to mount into.
3. State management via `data-state` attributes on both overlay and content elements.
4. Global API via `window.openModal()` / `window.closeModal()` — follows S2 pattern.
5. All colors via CSS custom properties — zero hardcoded values.
6. Lucide `x` icon for close button — `lucide.createIcons()` after innerHTML.
7. CSS transitions in `app.css` — scoped to `.js-modal-container [data-state]` pattern (mirroring toast pattern).
8. Must NOT collide with legacy `snipplets/modal.tpl` jQuery classes — use distinct `js-*` prefixes.
9. `--z-modal: 100` token already defined in `@theme` — use it, do not create a new one.
10. Body scroll lock: `document.body.style.overflow` manipulation with restore on close.
