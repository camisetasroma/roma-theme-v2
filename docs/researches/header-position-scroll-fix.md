# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Bug fix for the header's fixed positioning behavior. The header (`<header class="js-new-header fixed top-0 ...">`) disappears or renders behind the browser URL bar on iOS Chrome mobile. The issue is related to how `position: fixed; top: 0` interacts with iOS Chrome's dynamic viewport (the URL bar shrinks/expands on scroll, causing the browser to recalculate the viewport origin). The bug reportedly appeared after introducing the toast notification system. The header should remain visible and on top of all content regardless of browser, scroll position, or URL bar state.

## 2. Assumptions (if any)

- The bug is reproducible specifically on Chrome for iOS, where the dynamic toolbar (URL bar shrink/grow behavior) causes `position: fixed; top: 0` elements to misposition.
- The screenshot confirms the header is rendered behind/below the iOS Chrome URL bar — only a thin line of the header is visible at the very top of the content area.
- The toast system (`toast.js`) dynamically sets `container.style.top = headerHeight + "px"` and calls `header.offsetHeight` on load and resize — this forces a layout read on the header element but should not directly cause the positioning bug. However, the toast container is `position: fixed; top: 0; right: 0` (inline styles in `toast.tpl`), which may interact with the header's fixed stacking.
- The `overflow: hidden` class on the header element (`overflow-hidden` in `header-new.tpl:6`) may be contributing to clipping issues in combination with iOS Chrome's viewport handling.
- The `meta viewport` tag includes `user-scalable=no` (`layout.tpl:11`), which is relevant to iOS viewport behavior.
- Platform legacy CSS (`style-critical.tpl`, `style-async.scss.tpl`) contains multiple `position: fixed` and `z-index` rules for legacy header/nav components that may conflict with the new header.

## 3. Affected Architectural Domains

- **Template Layer**: `snipplets/header/header-new.tpl` — the header element's CSS classes and structure
- **Template Layer**: `snipplets/notification/toast.tpl` — the toast container's fixed positioning
- **Template Layer**: `layouts/layout.tpl` — meta viewport tag, toast snipplet inclusion order, header snipplet inclusion
- **Source Layer CSS**: `__src/css/app.css` — header state styles (lines 66-103), toast notification styles (lines 137-157), orphaned z-index tokens (`--z-toast`, `--z-modal`)
- **Source Layer JS**: `__src/js/modules/system/header.js` — scroll handler, header state management, advertising bar transform
- **Source Layer JS**: `__src/js/modules/system/toast.js` — reads `header.offsetHeight`, sets container top position
- **Platform CSS**: `static/css/style-critical.tpl` — legacy fixed positioning rules that may conflict

## 4. Applicable Invariants (Codes Only)

A1, A2, A4, A8, A9, S3, R3, R4, F4

## 5. Invariant Impact Explanation

- **A9** — The header uses `data-state="transparent"|"active"` for state management. Any fix must preserve this pattern. The fix should not introduce new state mechanisms.
- **A8 / F4** — The header active state background (`app.css:90`) currently uses a hardcoded `rgba(255, 255, 246, 0.7)`. This is an existing bug (documented in RISK 2). Any fix touching the header CSS should be aware of this but fixing it is a separate concern unless explicitly scoped in.
- **S3** — UI state preference order must be respected. Header positioning should rely on CSS (Tailwind classes or custom CSS rules), not runtime `element.style.*` overrides, unless the value must be computed dynamically.
- **R3** — The `js-new-header` class is the binding contract between `header-new.tpl` and `header.js`. Any CSS class changes on the header element must not break this binding.
- **R4** — CSS in `app.css` targets `.js-new-header[data-state=...]`. Any structural CSS changes must keep these selectors valid.
- **A1 / A4** — Fixes must be in `__src/css/app.css` (for CSS) or `__src/js/modules/system/` (for JS). Never directly edit `static/css/app.tpl`.

## 6. Risk Assessment (MEDIUM)

- The bug directly affects UX on a major mobile browser (Chrome on iOS).
- The fix involves CSS positioning behavior that varies across browsers and is influenced by iOS-specific viewport mechanics.
- Multiple `position: fixed` elements (header, toast container, legacy components) may interact in unexpected ways.
- The toast system was introduced alongside this bug, creating a causal correlation that needs investigation.
- The `overflow-hidden` on the header element is a potential aggravating factor specific to iOS.

## 7. Likely Impacted Areas (Scoped)

1. **`snipplets/header/header-new.tpl`** — The header element's Tailwind classes, particularly `fixed top-0 z-50 overflow-hidden`. The `overflow-hidden` class and potentially the stacking context via `z-50` need investigation.
2. **`__src/css/app.css`** — Lines 88-92 (header active state with `backdrop-filter: blur()`). `backdrop-filter` creates a new stacking context on iOS which can interfere with fixed positioning.
3. **`__src/js/modules/system/toast.js`** — The `updateContainerPosition()` function reads `header.offsetHeight` which forces layout reflow. The toast container's `position: fixed; top: 0` inline styles.
4. **`snipplets/notification/toast.tpl`** — The toast container's inline `style="position:fixed;top:0;right:0;..."` may need adjustment.
5. **`layouts/layout.tpl:11`** — The meta viewport tag (`user-scalable=no`, `minimum-scale=1.0`). iOS Chrome handles `dvh`/`svh`/`lvh` viewport units differently, and the viewport meta affects this.
6. **`__src/css/app.css:137-157`** — Toast CSS styles that are orphaned from the deleted toast system but still present — potential dead CSS that may still apply to the new toast container.

## 8. Visual / Component Surface Impact

- **Header**: The header must remain pinned at the absolute top of the visual viewport at all times, independent of iOS Chrome's URL bar state (expanded or collapsed). It must never slip behind the URL bar or render at negative top positions.
- **Toast Container**: The toast container is positioned relative to the header height. If the header position is fixed, the toast should remain below it. The toast container's `z-index: var(--z-toast)` (90) is higher than most elements but below the header's `z-50` (50 from Tailwind) — this is actually inverted: toast z-index 90 > header z-index 50. This could cause toast to render above header in some stacking contexts.
- **Header Spacer**: `.js-header-spacer` (`header-new.tpl:154`) provides spacing to prevent content from going behind the fixed header. Its height (`h-25 md:h-30`) is hardcoded and may not account for the advertising bar height dynamically.

## 9. Architectural Constraints Summary

- All CSS fixes must go in `__src/css/app.css` and be compiled via Tailwind CLI — never edit `static/css/app.tpl`.
- All JS fixes must go in `__src/js/modules/system/` and follow the named export + guard pattern.
- The `data-state` pattern on the header must be preserved.
- The `js-new-header` class must not be renamed or removed.
- The toast system (`toast.js`) is currently imported and invoked in `index.js` — it is active code. If the toast system is contributing to the bug, the fix must either adjust its behavior or decouple it from the header without breaking the architecture.
- The orphaned z-index tokens (`--z-toast: 90`, `--z-modal: 100`) in `@theme` are documented as orphaned in RISK 1 but are actually consumed by the toast container via `z-index: var(--z-toast)` in `toast.tpl`. This contradicts the RISK 1 documentation — they are NOT orphaned while the toast system exists.
- Any viewport-related fix (e.g., using `dvh` units, `-webkit-fill-available`) must be tested across Safari iOS, Chrome iOS, and Android Chrome to avoid cross-browser regressions.
