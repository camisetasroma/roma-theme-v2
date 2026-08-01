# ARCHITECTURE DRIFT AUDIT

**Date:** 2026-08-01
**Branch:** master
**Auditor:** Claude Code (Sonnet 5)

---

## Summary

The cart drawer's free-shipping/progressive-discount progress bars feature
(`snipplets/cart/cart-drawer-progress-bars.tpl`, added in commit `c42161c` — "feat: adding
discounts and shipping bar on cart") was implemented and shipped, but the architecture contract
was never updated to reflect it in full. The previous audit (`20260314-drift-audit.md`) covered
the `cart-drawer.js` module's introduction but not this follow-up feature. Additionally, one
pre-existing gap unrelated to this feature was found: the platform's `--accent-color` CSS
variable — already used across 5 templates before this feature — was never documented in the
color chain (A8/T2), despite being a fourth platform-injected color alongside
`--background-color`, `--primary-color`, `--text-color`.

**Totals:**
- VALID: 29 invariants (unchanged from 20260314 audit, re-verified against current code)
- DRIFTED: 4 invariants (A8/T2, Template Layer inventory, R3/R4, S1)
- WEAK: 0 (A10 was strengthened in the prior audit and remains adequate)
- REDUNDANT: 0

No invariants were relaxed or removed in this pass — all four items are additions of
previously undocumented, already-compliant implementation details. No forbidden-pattern
violations were found in the audited feature.

---

## Invariant Classification Table

| Invariant | Description | Status | Severity | Action Taken |
|-----------|-------------|--------|----------|--------------|
| **A8/T2** | Theme color chain / platform CSS variables | DRIFTED | MEDIUM | Added `--accent-color` to platform variable registry |
| **Template Layer (Sec. 2, RISK 1)** | Snipplet inventory | DRIFTED | LOW | Added `cart-drawer-progress-bars.tpl` |
| **R3/R4** | `js-*` class binding contract | DRIFTED | LOW | Added `.js-cart-progress-complete` |
| **S1** | `cart-drawer.js` state variable registry | DRIFTED | MEDIUM | Added `quantitySyncTimer` |
| A1–A7, A9–A14 | (see 20260314 audit) | VALID | — | None |
| D1–D3 | Data flow contracts | VALID | — | Re-verified: `refreshCart()` debounce still uses `fetch()` + `DOMParser` only, no new `LS.*` calls |
| S2–S5 | Window globals, UI state, Swiper map | VALID | — | No new `window.*` globals or state mechanisms introduced |
| L1–L6 | Library rules | VALID | — | None |
| R1, R2, R5–R7 | Dependency/build rules | VALID | — | None |
| F1–F10 | Forbidden patterns | VALID | — | Progress bars feature introduces no violations (colors use `var(--accent-color)`, not hardcoded values) |

---

## Drift Details

### DRIFT 1: A8/T2 — `--accent-color` Missing from Platform Color Registry (MEDIUM)

**Contract said:** Platform injects exactly three color variables: `--background-color`,
`--primary-color`, `--text-color`.

**Reality:** `style-colors.scss.tpl:20,33` also injects `--accent-color` from
`settings.accent_color`. It is consumed directly via `var(--accent-color)` — not through the
`@theme` token layer — in at least 6 places: `home-product-grid.tpl`,
`home-promo-marquee.tpl`, `home-product-carousel.tpl`, `home-faq.tpl`, `checkout.scss.tpl`,
and now `cart-drawer-progress-bars.tpl` (progress bar fill color).

**Root cause:** Pre-existing gap, not introduced by the cart feature — `--accent-color` usage
predates this audit's baseline (14/03 audit) but was never added to the registry. The new
progress bars snipplet just added one more (compliant) consumer.

**Correction:** `--accent-color` added to A8 and T2 as a fourth platform-injected variable,
with a note that it bypasses `@theme` and is used directly in templates.

---

### DRIFT 2: Template Layer Inventory — New Snipplet Undocumented (LOW)

**Contract said:** Section 2 (Template Layer) and Section 10 RISK 1 (cart drawer resolved risk)
listed `cart-drawer.tpl` but not its child snipplet.

**Reality:** `snipplets/cart/cart-drawer-progress-bars.tpl` exists, is included via
`{% snipplet "cart/cart-drawer-progress-bars.tpl" %}` at `cart-drawer.tpl:123`, and renders two
independent progress bars (free shipping threshold, progressive item-count discount tiers)
driven entirely by `cart.*` and `settings.cart_*` template variables — no JS involvement beyond
the existing cart refresh cycle.

**Correction:** Added to Section 2's snipplet description and Section 10's RISK 1 file list.

---

### DRIFT 3: R3/R4 — `.js-cart-progress-complete` Not Registered (LOW)

**Contract said:** R3/R4 registries for `cart-drawer.js` and cart-context CSS did not include
this class.

**Reality:** `.js-cart-progress-complete` is applied by the template (not by
`cart-drawer.js`) when a progress bar reaches 100%, and triggers a one-shot CSS animation
(`@keyframes progress-complete`, `app.css:431-439`). It is a `js-*`-prefixed class per naming
convention but is template-conditional rather than JS-controlled — an existing pattern
variation not previously seen elsewhere in the codebase (all other `js-*` classes in the R3/R4
registries are toggled by JS).

**Correction:** Added to both R3 and R4 with an explicit note that it is template-set, not
JS-set, so a future auditor doesn't expect to find it manipulated in `cart-drawer.js`.

---

### DRIFT 4: S1 — `quantitySyncTimer` State Variable Undocumented (MEDIUM)

**Contract said:** `cart-drawer.js` state: `pendingRemovals`, `removeSyncTimer`,
`badgeObserver`.

**Reality:** A fourth closure variable, `quantitySyncTimer`, was added: a 2-second debounce
timer that calls `refreshCart()` after clicks on `.js-cart-quantity-btn`, so the progress bars
(rendered server-side) reflect the updated cart subtotal/item count after the platform's own
AJAX quantity update completes.

**Correction:** Added to S1's `cart-drawer.js` state list.

---

## Strengthened Invariants

All changes applied directly to `docs/architecture-map.md`:

1. **A8** — Platform color variable registry expanded to 4 entries (`--accent-color` added);
   compact invariants block updated to list all four platform variables.
2. **T2** — Color chain description branches to cover `--accent-color`'s direct-consumption
   path (no `@theme` mapping) alongside the existing `@theme`-token path.
3. **Section 2 / Template Layer** — `cart-drawer-progress-bars.tpl` documented as a child
   snipplet of `cart-drawer.tpl`.
4. **Section 10 / RISK 1** — `cart-drawer-progress-bars.tpl` added to the cart drawer system
   file list.
5. **R3** — `.js-cart-progress-complete` added to `cart-drawer.js`'s class registry, flagged as
   template-controlled.
6. **R4** — `.js-cart-progress-complete` added to the state-driven CSS selector list, with its
   animation reference.
7. **S1** — `quantitySyncTimer` added to `cart-drawer.js`'s state variable list.
8. **Compact invariants block** — A8 and R3 one-liners updated to match.
