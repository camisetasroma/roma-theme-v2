# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A4, A8, A9, S3, R3, R4, F4

### Invariant Tension Check

- **A8/F4 vs scope**: The header active state in `app.css:90` uses hardcoded `rgba(255, 255, 246, 0.7)` — this is a documented bug (RISK 2). However, fixing hardcoded colors is OUT OF SCOPE for this ticket. The plan will note it but not address it.
- **A9 vs fix approach**: The `data-state` pattern must be preserved. The fix must work within the existing `transparent`/`active` state mechanism — no new states needed.
- **S3 vs positioning approach**: The fix should use CSS (classes or custom CSS rules) rather than JS `element.style.*` overrides, per S3 preference order. Any JS runtime values must only be used where CSS alone cannot solve the problem.
- No invariant violations are required. All fixes fit within existing architectural patterns.

### Risk Level
**MEDIUM** — The fix touches CSS positioning behavior that varies across mobile browsers (especially iOS Chrome's dynamic viewport). Multiple `position: fixed` elements coexist. Testing across iOS Chrome, iOS Safari, and Android Chrome is required.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
No changes required. No data layer is involved in this fix.

### 2.2 State / Hooks
No changes required. The existing `data-state="transparent"|"active"` pattern in `header.js` is correct and must be preserved as-is. No new state variables or cross-module signals are needed.

### 2.3 UI / Components

#### 2.3.1 Remove `overflow-hidden` from header element
- **File**: `snipplets/header/header-new.tpl`
- **What**: Remove the `overflow-hidden` Tailwind class from the `<header>` element (line 6).
- **Why**: `overflow: hidden` on a `position: fixed` element creates a containing block in some iOS browsers, which interferes with the element's anchoring to the viewport. The `overflow-hidden` was originally added to clip the advertising bar's `translateY(-N)` animation, but this clipping can be achieved with `overflow-y-clip` (CSS `overflow-y: clip`) which does not create a new formatting context on iOS. The `clip` value is a newer CSS property specifically designed to prevent scroll containers from being established — unlike `hidden`, it does not create a scroll container and does not interfere with `position: fixed` on iOS.
- **Constrained by**: R3 (must not rename/remove `js-new-header`), A9 (must preserve `data-state`)

#### 2.3.2 Replace with `overflow-y-clip` on the header element
- **File**: `snipplets/header/header-new.tpl`
- **What**: Add `overflow-y-clip` class to the `<header>` element to replace `overflow-hidden`.
- **Why**: This preserves the vertical clipping behavior for the advertising bar animation without creating a scroll container that causes iOS Chrome positioning bugs. `overflow-x` remains `visible` (the default), which is acceptable since no horizontal overflow occurs in the header.
- **Constrained by**: R3, R4 (CSS selectors targeting `.js-new-header[data-state=...]` remain valid)

#### 2.3.3 Add `-webkit-backdrop-filter` prefix for iOS compatibility
- **File**: `__src/css/app.css`
- **What**: Add `-webkit-backdrop-filter: blur(0.5rem)` alongside the existing `backdrop-filter: blur(0.5rem)` in the `.js-new-header[data-state="active"]` rule (line 91).
- **Why**: iOS Safari and Chrome on iOS require the `-webkit-` prefix for `backdrop-filter`. Without it, the property may not apply consistently, and the browser's fallback behavior can cause rendering inconsistencies with `position: fixed` elements. Ensuring the property is properly applied prevents the browser from entering an ambiguous rendering state.
- **Constrained by**: A4 (edit `app.css` source, not `app.tpl`), R4 (selector `.js-new-header[data-state="active"]` is preserved)

### 2.4 Styling

#### 2.4.1 Add `will-change: transform` to the header for compositor promotion
- **File**: `__src/css/app.css`
- **What**: Add `will-change: transform` to the `.js-new-header` base selector (not inside a `data-state` variant — it should always be promoted).
- **Why**: On iOS Chrome, `position: fixed` elements can be incorrectly composited when the dynamic URL bar triggers viewport resizing. Adding `will-change: transform` promotes the header to its own compositor layer, ensuring it stays anchored to the visual viewport regardless of dynamic toolbar behavior. This is a well-documented iOS workaround for fixed positioning issues with dynamic viewport.
- **Constrained by**: R4 (new CSS rule targeting `.js-new-header`), A4 (edit source CSS only)

#### 2.4.2 Add a new CSS rule for the header base positioning
- **File**: `__src/css/app.css`
- **What**: Add a base rule `.js-new-header { will-change: transform; }` in the header styles section, before the state-specific rules.
- **Why**: Centralizes the compositor hint in CSS rather than relying on JS `element.style`, respecting the S3 preference hierarchy (CSS over JS).
- **Constrained by**: S3, R4

### 2.5 Assets
No changes required. No new icons, images, or asset files are needed.

---

## 3. Execution Phases

### Phase 1: CSS compositor fix (resolves the core iOS bug)
1. Add `.js-new-header { will-change: transform; }` rule to `__src/css/app.css` in the header styles section (before line 66).
2. Add `-webkit-backdrop-filter: blur(0.5rem)` to the `.js-new-header[data-state="active"]` rule in `__src/css/app.css` (line 91).
3. Build CSS via Tailwind CLI to verify compilation.

**Testable**: Deploy/preview on iOS Chrome — the header should remain visible and fixed at the top of the viewport when scrolling, regardless of URL bar state.

### Phase 2: Overflow property fix (removes the containing block issue)
1. In `snipplets/header/header-new.tpl`, replace `overflow-hidden` with `overflow-y-clip` on the `<header>` element.
2. Verify the advertising bar slide-up animation still clips correctly within the header.

**Testable**: On all browsers — (a) header remains fixed at viewport top, (b) advertising bar slides up and is clipped correctly, (c) no horizontal overflow issues appear.

### Phase 3: Validation and cross-browser verification
1. Test on iOS Chrome (primary bug target).
2. Test on iOS Safari (regression check — Safari handles fixed positioning differently).
3. Test on Android Chrome (regression check).
4. Test on desktop browsers (regression check).
5. Verify header transitions between `transparent` and `active` states work correctly.
6. Verify toast notifications appear below the header (toast container `top` positioning unaffected).
7. Verify search overlay opens above the header correctly.

---

## 4. Risk Controls

### Edge Cases
- **iOS Chrome with URL bar fully expanded vs collapsed**: The header must remain pinned at `top: 0` of the visual viewport in both states. The `will-change: transform` compositor promotion should handle this.
- **Advertising bar present vs absent**: When no advertising bar exists, the header is shorter. The fix must not assume the advertising bar exists. The `overflow-y-clip` handles both cases since it only clips overflow that actually occurs.
- **Header state transitions during scroll**: Rapid scrolling that triggers `transparent → active` state changes must not cause flicker or repositioning. The CSS transition (`transition-[background-color,backdrop-filter] duration-300`) handles this.
- **Toast appearing while header is in transparent state**: The toast container reads `header.offsetHeight` — this is unaffected by the CSS-only fixes in this plan.
- **`overflow-y-clip` browser support**: `overflow: clip` is supported in all modern browsers (Chrome 90+, Safari 16+, Firefox 81+). iOS Chrome and Safari versions that exhibit the dynamic viewport bug are all modern enough to support `clip`. Tailwind v4 includes `overflow-y-clip` as a utility class.

### Regression Zones
- **Advertising bar clipping**: The `overflow-hidden → overflow-y-clip` change must be verified to still clip the advertising bar's `translateY` animation correctly. `overflow-y: clip` should clip vertically identically to `overflow: hidden`.
- **Header `backdrop-filter` visual appearance**: Adding `-webkit-backdrop-filter` should make the blur effect work on iOS where it may have been silently failing. This is a visual improvement, not a regression, but the appearance may change on iOS.
- **Stacking contexts**: `will-change: transform` creates a new stacking context. Since the header already has `z-50` and is a `position: fixed` element (which already creates a stacking context), this should not change z-index behavior. However, verify that toast and search overlays still stack correctly above/below the header.

### Strict Non-Modification Areas
- `__src/js/modules/system/header.js` — No JS changes. The scroll handler and state management logic are correct.
- `__src/js/modules/system/toast.js` — No changes. The toast positioning is not the cause of the bug.
- `__src/js/index.js` — No changes to module imports or invocation order.
- `layouts/layout.tpl` — No changes to script loading order or viewport meta tag.
- `config/settings.txt` — No new settings needed.
- `static/` — Never edit build outputs directly (A4).
- The hardcoded color in `app.css:90` (`rgba(255, 255, 246, 0.7)`) — Out of scope (A8/RISK 2, separate fix).
