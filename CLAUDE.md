# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Roma Theme V2 is a custom storefront theme for **Nuvemshop/Tiendanube**, a hosted e-commerce
platform (not a custom backend). There is no server code here — all commerce logic (cart, checkout,
customer accounts, search AJAX) is provided by the platform. This repo only contains:

- **Templates** (`.tpl` files, Twig-like syntax with Nuvemshop-specific tags/filters) rendered server-side by the platform.
- **A build pipeline** (Tailwind v4 + esbuild) that compiles `__src/` into static assets consumed by those templates.
- **Config files** (`config/*.txt`) that define the admin-configurable theme settings.

The compiled theme is uploaded/synced to Nuvemshop separately — there is no local dev server in this repo.

## Build commands

```bash
npm run dev          # watch CSS + JS together (development)
npm run watch:css    # Tailwind watch → static/css/app.tpl
npm run watch:js     # esbuild watch → static/js/gaius-v*.js (skips cache-busting step)
npm run build        # production build: build:css && build:js
npm run build:js     # runs pre-build.js (cache-busting) THEN esbuild
```

There is no lint script and no test suite (`npm test` intentionally exits with an error — no
testing framework is installed; validation is manual, in the Nuvemshop preview).

**Important:** after any change under `__src/`, always run `npm run build` (not
`node esbuild.config.mjs` directly). `pre-build.js` regenerates the `gaius-v{epoch}.js` bundle
filename and rewrites the reference in both `esbuild.config.mjs` and `layouts/layout.tpl` — this is
the cache-busting mechanism against Nuvemshop's CDN. Running esbuild alone leaves a stale filename
and the CDN keeps serving the old bundle.

## Architecture

### Dual-layer JS/CSS system

- **Legacy layer** — `static/js/store.js.tpl`, `static/js/external*.js.tpl`: jQuery-dependent code
  provided/managed by the Nuvemshop platform. Loaded inside `LS.ready.then()` in `layouts/layout.tpl`.
  Treat as reference-only; do not extend it.
- **Custom layer** — `__src/js/`: vanilla JS (no jQuery), bundled by esbuild into
  `static/js/gaius-v{epoch}.js`, loaded synchronously after the legacy scripts and after
  `lucide.min.js`. **All new JS work happens here.**
- **CSS** — `__src/css/app.css` is the Tailwind v4 entry point (no `tailwind.config.js`; all design
  tokens live in the `@theme` block). It's compiled to `static/css/app.tpl`. Platform-managed SCSS
  templates (`style-colors.scss.tpl`, `style-async.scss.tpl`, `style-critical.tpl`) inject
  admin-configured colors as CSS custom properties (`--background-color`, `--primary-color`,
  `--text-color`), which `app.css`'s `@theme` block maps to semantic tokens (`--color-bg`,
  `--color-fg`, etc). **Never hardcode theme colors** — always go through these CSS variables or
  Tailwind tokens.

### Custom JS module system (`__src/js/`)

```
__src/js/index.js                 # single entry point — imports + invokes every module
__src/js/modules/system/          # global modules loaded on every page (header, menu, search,
                                   #   toast, modal, cart-drawer, item-card-quickbuy)
__src/js/modules/home/            # homepage-only modules (hero carousel, product carousel)
__src/js/modules/category/        # category-page-only modules (dropdown, infinite scroll,
                                   #   filters, sorting)
```

Rules that the existing code follows strictly (see `.claude/architecture-map.md` for the full,
exhaustive contract — it documents every module, every `js-*` class contract, and every
`window.*` global in detail):

- Every module is a **named export**, imported and invoked explicitly in `index.js`. No default
  exports, no self-executing/side-effectful imports.
- Every module's entry function guards on its root DOM element first (`if (!element) return;`) —
  modules for home/category pages are loaded globally but no-op when their markup isn't present.
- **No imports between sibling modules.** The only inter-module communication is `window.*`
  globals (e.g. `window.openModal`, `window.showToast`, `window.openCartDrawer`,
  `window.setHeaderMenuActive`), always called with optional chaining (`window.fn?.()`) on the
  consuming side.
- Templates and JS are bound through `js-*` prefixed CSS classes (never used for styling) and
  `data-*` attributes (state + data passing). Renaming one requires updating the other side.
- After inserting HTML containing `<i data-lucide="...">`, call `lucide.createIcons()`.
- Swiper and Lucide are loaded as vendored globals via the platform's script chain — never install
  them via npm or import as ES modules.
- `LS.*` platform APIs may only be called from `store.js.tpl`/template `<script>` blocks, except
  `LS.addItem`/`LS.removeItem` which are also permitted directly in cart modules.

### Template layer

```
layouts/layout.tpl      # master layout: <head>, script/style loading order, global snipplets
templates/*.tpl         # one per page type (home, product, category, cart, search, account/...)
snipplets/<domain>/     # reusable components organized by domain (header, home, navigation,
                        #   grid, product, cart, shipping, forms, svg, social, notification, ...)
```

- Includes use `{% snipplet "path.tpl" %}` or `{% include "path.tpl" %}` (both are used in this
  codebase). New snipplets go inside an existing (or new) domain folder — never at `snipplets/`
  root (a handful of legacy flat files exist there; they are not a pattern to follow).
- The homepage section order is fully admin-configurable (`settings.home_order_position_0..12`),
  routed through `snipplets/home/home-section-switch.tpl`. Never assume a fixed section order or
  add a section directly in `home.tpl` outside that router.
- Icons: **Lucide is canonical** (`<i data-lucide="icon-name">`). `snipplets/svg/` is legacy and
  mid-migration to Lucide — only use an SVG snipplet when the icon doesn't exist in Lucide, and
  never add new files there.

### Config layer (`config/`)

- `settings.txt` — all admin-exposed theme settings (colors, fonts, header, menu, per-homepage-section
  options, cart, product grid, etc.), consumed in templates via `{{ settings.NAME }}`. New settings
  follow the existing `snake_case` name + category/meta/title/field grouping.
- `sections.txt` — admin-curated product list sections (`primary`, `carousel_tab_1/2/3`), consumed
  via `{{ sections.NAME.products }}`.
- `defaults.txt`, `translations.txt`, `variants.txt`, `data.json` — defaults, i18n strings, theme
  variants, and compiled asset metadata respectively.

## The `.claude/` workflow (research → plan → implement)

This project uses a deliberate, staged workflow for non-trivial feature work, driven by three
prompt templates and one standing contract:

- **`.claude/architecture-map.md`** — the authoritative, exhaustive architecture contract
  (invariants coded A1-A14, data-flow D1-D3, state S1-S5, library rules L1-L6, forbidden patterns
  F1-F10). It takes priority over any feature request if they conflict. Read this file for anything
  beyond the summary above — it is kept current and is far more detailed.
- **`.claude/research-prompt.md`** → produces `.claude/researches/<feature-slug>.md`: a scoped,
  no-code analysis of a feature request against the architecture contract (affected domains,
  applicable invariants, risk level). No implementation planning happens here.
- **`.claude/plan-prompt.md`** → produces `.claude/plans/<feature-slug>.md`: a layered, phased
  implementation plan derived strictly from the research file. Still no code.
- **`.claude/implemetation-prompt.md`** → actually writes code, strictly within the approved plan's
  phases, after checking the codebase for 2+ similar existing implementations to match their
  pattern. Ends with a compliance report against the invariants.
- **`.claude/update-architecture.md`** → an audit mode that diffs the architecture contract against
  real implementation and writes a report to `.claude/architecture-drift-reports/`, strengthening or
  relaxing invariants as needed.

When asked to implement a nontrivial feature or fix in this repo, prefer following this
research → plan → implement staging (checking `.claude/researches/` and `.claude/plans/` for
related prior work first) rather than jumping straight to code. Feature specs in this workflow are
typically written in Portuguese.

## Known issues (tracked in architecture-map.md, not yet fixed)

A handful of hardcoded theme colors exist as known bugs, not precedent (`product-carousel.js`
pagination colors, `rgba(255,255,246,0.7)` in `home-product-carousel.tpl` and `category.tpl`) — see
architecture-map.md section on "Hardcoded Colors" before touching color logic in those files.
