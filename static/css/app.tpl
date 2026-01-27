/*! tailwindcss v4.1.18 | MIT License | https://tailwindcss.com */
@layer properties {
  @supports (((-webkit-hyphens: none)) and (not (margin-trim: inline))) or ((-moz-orient: inline) and (not (color: rgb(from red r g b)))) {
    *, :before, :after, ::backdrop {
      --tw-rotate-x: initial;
      --tw-rotate-y: initial;
      --tw-rotate-z: initial;
      --tw-skew-x: initial;
      --tw-skew-y: initial;
      --tw-border-style: solid;
      --tw-font-weight: initial;
      --tw-tracking: initial;
      --tw-outline-style: solid;
      --tw-blur: initial;
      --tw-brightness: initial;
      --tw-contrast: initial;
      --tw-grayscale: initial;
      --tw-hue-rotate: initial;
      --tw-invert: initial;
      --tw-opacity: initial;
      --tw-saturate: initial;
      --tw-sepia: initial;
      --tw-drop-shadow: initial;
      --tw-drop-shadow-color: initial;
      --tw-drop-shadow-alpha: 100%;
      --tw-drop-shadow-size: initial;
      --tw-backdrop-blur: initial;
      --tw-backdrop-brightness: initial;
      --tw-backdrop-contrast: initial;
      --tw-backdrop-grayscale: initial;
      --tw-backdrop-hue-rotate: initial;
      --tw-backdrop-invert: initial;
      --tw-backdrop-opacity: initial;
      --tw-backdrop-saturate: initial;
      --tw-backdrop-sepia: initial;
      --tw-duration: initial;
      --tw-ease: initial;
    }
  }
}

@layer theme {
  :root, :host {
    --font-sans: var(--font-body);
    --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
    --color-amber-300: oklch(87.9% .169 91.605);
    --color-black: #000;
    --color-white: #fff;
    --spacing: .25rem;
    --text-xs: .75rem;
    --text-xs--line-height: calc(1 / .75);
    --text-sm: .875rem;
    --text-sm--line-height: calc(1.25 / .875);
    --text-base: 1rem;
    --text-base--line-height: calc(1.5 / 1);
    --text-xl: 1.25rem;
    --text-xl--line-height: calc(1.75 / 1.25);
    --text-2xl: 1.5rem;
    --text-2xl--line-height: calc(2 / 1.5);
    --text-3xl: 1.875rem;
    --text-3xl--line-height: calc(2.25 / 1.875);
    --text-4xl: 2.25rem;
    --text-4xl--line-height: calc(2.5 / 2.25);
    --text-5xl: 3rem;
    --text-5xl--line-height: 1;
    --text-6xl: 3.75rem;
    --text-6xl--line-height: 1;
    --font-weight-normal: 400;
    --font-weight-medium: 500;
    --font-weight-semibold: 600;
    --font-weight-bold: 700;
    --tracking-wider: .05em;
    --tracking-widest: .1em;
    --ease-in: cubic-bezier(.4, 0, 1, 1);
    --ease-in-out: cubic-bezier(.4, 0, .2, 1);
    --blur-sm: 8px;
    --default-transition-duration: .15s;
    --default-transition-timing-function: cubic-bezier(.4, 0, .2, 1);
    --default-font-family: var(--font-sans);
    --default-mono-font-family: var(--font-mono);
    --color-bg: var(--background-color);
    --color-fg: var(--primary-color);
    --color-secondary: var(--text-color);
    --color-bg-subtle: var(--background-color);
  }

  @supports (color: color-mix(in lab, red, red)) {
    :root, :host {
      --color-bg-subtle: color-mix(in srgb, var(--background-color) 95%, var(--primary-color) 5%);
    }
  }

  :root, :host {
    --color-fg-muted: var(--primary-color);
  }

  @supports (color: color-mix(in lab, red, red)) {
    :root, :host {
      --color-fg-muted: color-mix(in srgb, var(--primary-color) 60%, var(--background-color) 40%);
    }
  }

  :root, :host {
    --font-heading: var(--font-headings);
    --transition-duration-300: .3s;
  }
}

@layer base {
  *, :after, :before, ::backdrop {
    box-sizing: border-box;
    border: 0 solid;
    margin: 0;
    padding: 0;
  }

  ::file-selector-button {
    box-sizing: border-box;
    border: 0 solid;
    margin: 0;
    padding: 0;
  }

  html, :host {
    -webkit-text-size-adjust: 100%;
    tab-size: 4;
    line-height: 1.5;
    font-family: var(--default-font-family, ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");
    font-feature-settings: var(--default-font-feature-settings, normal);
    font-variation-settings: var(--default-font-variation-settings, normal);
    -webkit-tap-highlight-color: transparent;
  }

  hr {
    height: 0;
    color: inherit;
    border-top-width: 1px;
  }

  abbr:where([title]) {
    -webkit-text-decoration: underline dotted;
    text-decoration: underline dotted;
  }

  h1, h2, h3, h4, h5, h6 {
    font-size: inherit;
    font-weight: inherit;
  }

  a {
    color: inherit;
    -webkit-text-decoration: inherit;
    -webkit-text-decoration: inherit;
    -webkit-text-decoration: inherit;
    text-decoration: inherit;
  }

  b, strong {
    font-weight: bolder;
  }

  code, kbd, samp, pre {
    font-family: var(--default-mono-font-family, ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace);
    font-feature-settings: var(--default-mono-font-feature-settings, normal);
    font-variation-settings: var(--default-mono-font-variation-settings, normal);
    font-size: 1em;
  }

  small {
    font-size: 80%;
  }

  sub, sup {
    vertical-align: baseline;
    font-size: 75%;
    line-height: 0;
    position: relative;
  }

  sub {
    bottom: -.25em;
  }

  sup {
    top: -.5em;
  }

  table {
    text-indent: 0;
    border-color: inherit;
    border-collapse: collapse;
  }

  :-moz-focusring {
    outline: auto;
  }

  progress {
    vertical-align: baseline;
  }

  summary {
    display: list-item;
  }

  ol, ul, menu {
    list-style: none;
  }

  img, svg, video, canvas, audio, iframe, embed, object {
    vertical-align: middle;
    display: block;
  }

  img, video {
    max-width: 100%;
    height: auto;
  }

  button, input, select, optgroup, textarea {
    font: inherit;
    font-feature-settings: inherit;
    font-variation-settings: inherit;
    letter-spacing: inherit;
    color: inherit;
    opacity: 1;
    background-color: #0000;
    border-radius: 0;
  }

  ::file-selector-button {
    font: inherit;
    font-feature-settings: inherit;
    font-variation-settings: inherit;
    letter-spacing: inherit;
    color: inherit;
    opacity: 1;
    background-color: #0000;
    border-radius: 0;
  }

  :where(select:is([multiple], [size])) optgroup {
    font-weight: bolder;
  }

  :where(select:is([multiple], [size])) optgroup option {
    padding-inline-start: 20px;
  }

  ::file-selector-button {
    margin-inline-end: 4px;
  }

  ::placeholder {
    opacity: 1;
  }

  @supports (not ((-webkit-appearance: -apple-pay-button))) or (contain-intrinsic-size: 1px) {
    ::placeholder {
      color: currentColor;
    }

    @supports (color: color-mix(in lab, red, red)) {
      ::placeholder {
        color: color-mix(in oklab, currentcolor 50%, transparent);
      }
    }
  }

  textarea {
    resize: vertical;
  }

  ::-webkit-search-decoration {
    -webkit-appearance: none;
  }

  ::-webkit-date-and-time-value {
    min-height: 1lh;
    text-align: inherit;
  }

  ::-webkit-datetime-edit {
    display: inline-flex;
  }

  ::-webkit-datetime-edit-fields-wrapper {
    padding: 0;
  }

  ::-webkit-datetime-edit {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-year-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-month-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-day-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-hour-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-minute-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-second-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-millisecond-field {
    padding-block: 0;
  }

  ::-webkit-datetime-edit-meridiem-field {
    padding-block: 0;
  }

  ::-webkit-calendar-picker-indicator {
    line-height: 1;
  }

  :-moz-ui-invalid {
    box-shadow: none;
  }

  button, input:where([type="button"], [type="reset"], [type="submit"]) {
    appearance: button;
  }

  ::file-selector-button {
    appearance: button;
  }

  ::-webkit-inner-spin-button {
    height: auto;
  }

  ::-webkit-outer-spin-button {
    height: auto;
  }

  [hidden]:where(:not([hidden="until-found"])) {
    display: none !important;
  }
}

@layer components;

@layer utilities {
  .collapse {
    visibility: collapse;
  }

  .invisible {
    visibility: hidden;
  }

  .visible {
    visibility: visible;
  }

  .absolute {
    position: absolute;
  }

  .fixed {
    position: fixed;
  }

  .relative {
    position: relative;
  }

  .sticky {
    position: sticky;
  }

  .inset-0 {
    inset: calc(var(--spacing) * 0);
  }

  .inset-x-0 {
    inset-inline: calc(var(--spacing) * 0);
  }

  .top-0 {
    top: calc(var(--spacing) * 0);
  }

  .right-0 {
    right: calc(var(--spacing) * 0);
  }

  .bottom-0 {
    bottom: calc(var(--spacing) * 0);
  }

  .left-0 {
    left: calc(var(--spacing) * 0);
  }

  .z-50 {
    z-index: 50;
  }

  .order-0 {
    order: 0;
  }

  .order-1 {
    order: 1;
  }

  .order-2 {
    order: 2;
  }

  .order-3 {
    order: 3;
  }

  .order-4 {
    order: 4;
  }

  .order-5 {
    order: 5;
  }

  .order-6 {
    order: 6;
  }

  .order-7 {
    order: 7;
  }

  .order-8 {
    order: 8;
  }

  .order-9 {
    order: 9;
  }

  .order-10 {
    order: 10;
  }

  .order-11 {
    order: 11;
  }

  .order-12 {
    order: 12;
  }

  .order-first {
    order: -9999;
  }

  .order-last {
    order: 9999;
  }

  .col-1 {
    grid-column: 1;
  }

  .col-2 {
    grid-column: 2;
  }

  .col-3 {
    grid-column: 3;
  }

  .col-4 {
    grid-column: 4;
  }

  .col-5 {
    grid-column: 5;
  }

  .col-6 {
    grid-column: 6;
  }

  .col-7 {
    grid-column: 7;
  }

  .col-8 {
    grid-column: 8;
  }

  .col-9 {
    grid-column: 9;
  }

  .col-10 {
    grid-column: 10;
  }

  .col-11 {
    grid-column: 11;
  }

  .col-12 {
    grid-column: 12;
  }

  .col-auto {
    grid-column: auto;
  }

  .float-left {
    float: left;
  }

  .float-none {
    float: none;
  }

  .float-right {
    float: right;
  }

  .clear-both {
    clear: both;
  }

  .container {
    width: 100%;
  }

  @media (min-width: 40rem) {
    .container {
      max-width: 40rem;
    }
  }

  @media (min-width: 48rem) {
    .container {
      max-width: 48rem;
    }
  }

  @media (min-width: 64rem) {
    .container {
      max-width: 64rem;
    }
  }

  @media (min-width: 80rem) {
    .container {
      max-width: 80rem;
    }
  }

  @media (min-width: 96rem) {
    .container {
      max-width: 96rem;
    }
  }

  .m-0 {
    margin: calc(var(--spacing) * 0);
  }

  .m-1 {
    margin: calc(var(--spacing) * 1);
  }

  .m-2 {
    margin: calc(var(--spacing) * 2);
  }

  .m-3 {
    margin: calc(var(--spacing) * 3);
  }

  .m-4 {
    margin: calc(var(--spacing) * 4);
  }

  .m-5 {
    margin: calc(var(--spacing) * 5);
  }

  .m-auto {
    margin: auto;
  }

  .mx-0 {
    margin-inline: calc(var(--spacing) * 0);
  }

  .mx-1 {
    margin-inline: calc(var(--spacing) * 1);
  }

  .mx-2 {
    margin-inline: calc(var(--spacing) * 2);
  }

  .mx-3 {
    margin-inline: calc(var(--spacing) * 3);
  }

  .mx-4 {
    margin-inline: calc(var(--spacing) * 4);
  }

  .mx-5 {
    margin-inline: calc(var(--spacing) * 5);
  }

  .mx-10 {
    margin-inline: calc(var(--spacing) * 10);
  }

  .mx-auto {
    margin-inline: auto;
  }

  .my-0 {
    margin-block: calc(var(--spacing) * 0);
  }

  .my-1 {
    margin-block: calc(var(--spacing) * 1);
  }

  .my-2 {
    margin-block: calc(var(--spacing) * 2);
  }

  .my-3 {
    margin-block: calc(var(--spacing) * 3);
  }

  .my-4 {
    margin-block: calc(var(--spacing) * 4);
  }

  .my-5 {
    margin-block: calc(var(--spacing) * 5);
  }

  .my-auto {
    margin-block: auto;
  }

  .mt-0 {
    margin-top: calc(var(--spacing) * 0);
  }

  .mt-0\.5 {
    margin-top: calc(var(--spacing) * .5);
  }

  .mt-1 {
    margin-top: calc(var(--spacing) * 1);
  }

  .mt-2 {
    margin-top: calc(var(--spacing) * 2);
  }

  .mt-3 {
    margin-top: calc(var(--spacing) * 3);
  }

  .mt-4 {
    margin-top: calc(var(--spacing) * 4);
  }

  .mt-5 {
    margin-top: calc(var(--spacing) * 5);
  }

  .mr-0 {
    margin-right: calc(var(--spacing) * 0);
  }

  .mr-1 {
    margin-right: calc(var(--spacing) * 1);
  }

  .mr-2 {
    margin-right: calc(var(--spacing) * 2);
  }

  .mr-3 {
    margin-right: calc(var(--spacing) * 3);
  }

  .mb-0 {
    margin-bottom: calc(var(--spacing) * 0);
  }

  .mb-1 {
    margin-bottom: calc(var(--spacing) * 1);
  }

  .mb-2 {
    margin-bottom: calc(var(--spacing) * 2);
  }

  .mb-3 {
    margin-bottom: calc(var(--spacing) * 3);
  }

  .mb-4 {
    margin-bottom: calc(var(--spacing) * 4);
  }

  .mb-5 {
    margin-bottom: calc(var(--spacing) * 5);
  }

  .mb-6 {
    margin-bottom: calc(var(--spacing) * 6);
  }

  .ml-1 {
    margin-left: calc(var(--spacing) * 1);
  }

  .ml-2 {
    margin-left: calc(var(--spacing) * 2);
  }

  .ml-3 {
    margin-left: calc(var(--spacing) * 3);
  }

  .ml-4 {
    margin-left: calc(var(--spacing) * 4);
  }

  .block {
    display: block;
  }

  .flex {
    display: flex;
  }

  .grid {
    display: grid;
  }

  .hidden {
    display: none;
  }

  .inline {
    display: inline;
  }

  .inline-block {
    display: inline-block;
  }

  .inline-flex {
    display: inline-flex;
  }

  .list-item {
    display: list-item;
  }

  .table {
    display: table;
  }

  .h-3 {
    height: calc(var(--spacing) * 3);
  }

  .h-4 {
    height: calc(var(--spacing) * 4);
  }

  .h-5 {
    height: calc(var(--spacing) * 5);
  }

  .h-6 {
    height: calc(var(--spacing) * 6);
  }

  .h-7 {
    height: calc(var(--spacing) * 7);
  }

  .h-8 {
    height: calc(var(--spacing) * 8);
  }

  .h-12 {
    height: calc(var(--spacing) * 12);
  }

  .h-25 {
    height: calc(var(--spacing) * 25);
  }

  .h-100 {
    height: calc(var(--spacing) * 100);
  }

  .h-\[596\.4px\] {
    height: 596.4px;
  }

  .h-\[819\.2px\] {
    height: 819.2px;
  }

  .h-auto {
    height: auto;
  }

  .h-full {
    height: 100%;
  }

  .max-h-12 {
    max-height: calc(var(--spacing) * 12);
  }

  .max-h-16 {
    max-height: calc(var(--spacing) * 16);
  }

  .w-3 {
    width: calc(var(--spacing) * 3);
  }

  .w-4 {
    width: calc(var(--spacing) * 4);
  }

  .w-5 {
    width: calc(var(--spacing) * 5);
  }

  .w-6 {
    width: calc(var(--spacing) * 6);
  }

  .w-100 {
    width: calc(var(--spacing) * 100);
  }

  .w-auto {
    width: auto;
  }

  .w-full {
    width: 100%;
  }

  .flex-1 {
    flex: 1;
  }

  .flex-shrink {
    flex-shrink: 1;
  }

  .flex-shrink-0 {
    flex-shrink: 0;
  }

  .flex-shrink-1 {
    flex-shrink: 1;
  }

  .flex-grow {
    flex-grow: 1;
  }

  .flex-grow-0 {
    flex-grow: 0;
  }

  .flex-grow-1 {
    flex-grow: 1;
  }

  .border-collapse {
    border-collapse: collapse;
  }

  .transform {
    transform: var(--tw-rotate-x, ) var(--tw-rotate-y, ) var(--tw-rotate-z, ) var(--tw-skew-x, ) var(--tw-skew-y, );
  }

  .resize {
    resize: both;
  }

  .grid-cols-1 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }

  .flex-col {
    flex-direction: column;
  }

  .flex-row {
    flex-direction: row;
  }

  .flex-row-reverse {
    flex-direction: row-reverse;
  }

  .flex-nowrap {
    flex-wrap: nowrap;
  }

  .flex-wrap {
    flex-wrap: wrap;
  }

  .flex-wrap-reverse {
    flex-wrap: wrap-reverse;
  }

  .items-center {
    align-items: center;
  }

  .items-end {
    align-items: flex-end;
  }

  .items-start {
    align-items: flex-start;
  }

  .justify-between {
    justify-content: space-between;
  }

  .justify-center {
    justify-content: center;
  }

  .justify-end {
    justify-content: flex-end;
  }

  .gap-1 {
    gap: calc(var(--spacing) * 1);
  }

  .gap-2 {
    gap: calc(var(--spacing) * 2);
  }

  .gap-2\.5 {
    gap: calc(var(--spacing) * 2.5);
  }

  .gap-4 {
    gap: calc(var(--spacing) * 4);
  }

  .gap-6 {
    gap: calc(var(--spacing) * 6);
  }

  .gap-8 {
    gap: calc(var(--spacing) * 8);
  }

  .gap-12 {
    gap: calc(var(--spacing) * 12);
  }

  .gap-x-4 {
    column-gap: calc(var(--spacing) * 4);
  }

  .gap-x-5 {
    column-gap: calc(var(--spacing) * 5);
  }

  .gap-x-6 {
    column-gap: calc(var(--spacing) * 6);
  }

  .gap-y-4 {
    row-gap: calc(var(--spacing) * 4);
  }

  .self-stretch {
    align-self: stretch;
  }

  .overflow-hidden {
    overflow: hidden;
  }

  .border {
    border-style: var(--tw-border-style);
    border-width: 1px;
  }

  .border-t {
    border-top-style: var(--tw-border-style);
    border-top-width: 1px;
  }

  .border-bg {
    border-color: var(--color-bg);
  }

  .border-white {
    border-color: var(--color-white);
  }

  .bg-bg {
    background-color: var(--color-bg);
  }

  .bg-bg-subtle {
    background-color: var(--color-bg-subtle);
  }

  .bg-black {
    background-color: var(--color-black);
  }

  .bg-black\/35 {
    background-color: #00000059;
  }

  @supports (color: color-mix(in lab, red, red)) {
    .bg-black\/35 {
      background-color: color-mix(in oklab, var(--color-black) 35%, transparent);
    }
  }

  .bg-fg {
    background-color: var(--color-fg);
  }

  .bg-secondary {
    background-color: var(--color-secondary);
  }

  .bg-transparent {
    background-color: #0000;
  }

  .bg-white {
    background-color: var(--color-white);
  }

  .fill-amber-300 {
    fill: var(--color-amber-300);
  }

  .fill-bg {
    fill: var(--color-bg);
  }

  .fill-fg {
    fill: var(--color-fg);
  }

  .object-cover {
    object-fit: cover;
  }

  .p-0 {
    padding: calc(var(--spacing) * 0);
  }

  .p-1 {
    padding: calc(var(--spacing) * 1);
  }

  .p-2 {
    padding: calc(var(--spacing) * 2);
  }

  .p-2\.5 {
    padding: calc(var(--spacing) * 2.5);
  }

  .p-3 {
    padding: calc(var(--spacing) * 3);
  }

  .p-4 {
    padding: calc(var(--spacing) * 4);
  }

  .p-5 {
    padding: calc(var(--spacing) * 5);
  }

  .p-6 {
    padding: calc(var(--spacing) * 6);
  }

  .p-8 {
    padding: calc(var(--spacing) * 8);
  }

  .px-0 {
    padding-inline: calc(var(--spacing) * 0);
  }

  .px-1 {
    padding-inline: calc(var(--spacing) * 1);
  }

  .px-2 {
    padding-inline: calc(var(--spacing) * 2);
  }

  .px-3 {
    padding-inline: calc(var(--spacing) * 3);
  }

  .px-4 {
    padding-inline: calc(var(--spacing) * 4);
  }

  .px-5 {
    padding-inline: calc(var(--spacing) * 5);
  }

  .px-6 {
    padding-inline: calc(var(--spacing) * 6);
  }

  .px-8 {
    padding-inline: calc(var(--spacing) * 8);
  }

  .px-16 {
    padding-inline: calc(var(--spacing) * 16);
  }

  .px-416 {
    padding-inline: calc(var(--spacing) * 416);
  }

  .py-0 {
    padding-block: calc(var(--spacing) * 0);
  }

  .py-1 {
    padding-block: calc(var(--spacing) * 1);
  }

  .py-2 {
    padding-block: calc(var(--spacing) * 2);
  }

  .py-3 {
    padding-block: calc(var(--spacing) * 3);
  }

  .py-4 {
    padding-block: calc(var(--spacing) * 4);
  }

  .py-5 {
    padding-block: calc(var(--spacing) * 5);
  }

  .py-5\.5 {
    padding-block: calc(var(--spacing) * 5.5);
  }

  .py-8 {
    padding-block: calc(var(--spacing) * 8);
  }

  .pt-0 {
    padding-top: calc(var(--spacing) * 0);
  }

  .pt-1 {
    padding-top: calc(var(--spacing) * 1);
  }

  .pt-2 {
    padding-top: calc(var(--spacing) * 2);
  }

  .pt-3 {
    padding-top: calc(var(--spacing) * 3);
  }

  .pt-4 {
    padding-top: calc(var(--spacing) * 4);
  }

  .pr-0 {
    padding-right: calc(var(--spacing) * 0);
  }

  .pr-4 {
    padding-right: calc(var(--spacing) * 4);
  }

  .pb-0 {
    padding-bottom: calc(var(--spacing) * 0);
  }

  .pb-1 {
    padding-bottom: calc(var(--spacing) * 1);
  }

  .pb-2 {
    padding-bottom: calc(var(--spacing) * 2);
  }

  .pb-3 {
    padding-bottom: calc(var(--spacing) * 3);
  }

  .pb-4 {
    padding-bottom: calc(var(--spacing) * 4);
  }

  .pb-6 {
    padding-bottom: calc(var(--spacing) * 6);
  }

  .pb-8 {
    padding-bottom: calc(var(--spacing) * 8);
  }

  .pb-10 {
    padding-bottom: calc(var(--spacing) * 10);
  }

  .pl-0 {
    padding-left: calc(var(--spacing) * 0);
  }

  .pl-2 {
    padding-left: calc(var(--spacing) * 2);
  }

  .text-center {
    text-align: center;
  }

  .text-left {
    text-align: left;
  }

  .text-right {
    text-align: right;
  }

  .align-baseline {
    vertical-align: baseline;
  }

  .align-bottom {
    vertical-align: bottom;
  }

  .align-middle {
    vertical-align: middle;
  }

  .align-sub {
    vertical-align: sub;
  }

  .align-text-bottom {
    vertical-align: text-bottom;
  }

  .align-text-top {
    vertical-align: text-top;
  }

  .align-top {
    vertical-align: top;
  }

  .font-heading {
    font-family: var(--font-heading);
  }

  .font-sans {
    font-family: var(--font-sans);
  }

  .text-2xl {
    font-size: var(--text-2xl);
    line-height: var(--tw-leading, var(--text-2xl--line-height));
  }

  .text-3xl {
    font-size: var(--text-3xl);
    line-height: var(--tw-leading, var(--text-3xl--line-height));
  }

  .text-4xl {
    font-size: var(--text-4xl);
    line-height: var(--tw-leading, var(--text-4xl--line-height));
  }

  .text-5xl {
    font-size: var(--text-5xl);
    line-height: var(--tw-leading, var(--text-5xl--line-height));
  }

  .text-base {
    font-size: var(--text-base);
    line-height: var(--tw-leading, var(--text-base--line-height));
  }

  .text-sm {
    font-size: var(--text-sm);
    line-height: var(--tw-leading, var(--text-sm--line-height));
  }

  .text-xl {
    font-size: var(--text-xl);
    line-height: var(--tw-leading, var(--text-xl--line-height));
  }

  .text-xs {
    font-size: var(--text-xs);
    line-height: var(--tw-leading, var(--text-xs--line-height));
  }

  .font-bold {
    --tw-font-weight: var(--font-weight-bold);
    font-weight: var(--font-weight-bold);
  }

  .font-medium {
    --tw-font-weight: var(--font-weight-medium);
    font-weight: var(--font-weight-medium);
  }

  .font-normal {
    --tw-font-weight: var(--font-weight-normal);
    font-weight: var(--font-weight-normal);
  }

  .font-semibold {
    --tw-font-weight: var(--font-weight-semibold);
    font-weight: var(--font-weight-semibold);
  }

  .tracking-wider {
    --tw-tracking: var(--tracking-wider);
    letter-spacing: var(--tracking-wider);
  }

  .tracking-widest {
    --tw-tracking: var(--tracking-widest);
    letter-spacing: var(--tracking-widest);
  }

  .whitespace-nowrap {
    white-space: nowrap;
  }

  .text-bg {
    color: var(--color-bg);
  }

  .text-fg {
    color: var(--color-fg);
  }

  .text-secondary {
    color: var(--color-secondary);
  }

  .text-white {
    color: var(--color-white);
  }

  .uppercase {
    text-transform: uppercase;
  }

  .underline {
    text-decoration-line: underline;
  }

  .opacity-40 {
    opacity: .4;
  }

  .opacity-50 {
    opacity: .5;
  }

  .opacity-60 {
    opacity: .6;
  }

  .opacity-80 {
    opacity: .8;
  }

  .opacity-90 {
    opacity: .9;
  }

  .outline {
    outline-style: var(--tw-outline-style);
    outline-width: 1px;
  }

  .blur {
    --tw-blur: blur(8px);
    filter: var(--tw-blur, ) var(--tw-brightness, ) var(--tw-contrast, ) var(--tw-grayscale, ) var(--tw-hue-rotate, ) var(--tw-invert, ) var(--tw-saturate, ) var(--tw-sepia, ) var(--tw-drop-shadow, );
  }

  .invert {
    --tw-invert: invert(100%);
    filter: var(--tw-blur, ) var(--tw-brightness, ) var(--tw-contrast, ) var(--tw-grayscale, ) var(--tw-hue-rotate, ) var(--tw-invert, ) var(--tw-saturate, ) var(--tw-sepia, ) var(--tw-drop-shadow, );
  }

  .filter {
    filter: var(--tw-blur, ) var(--tw-brightness, ) var(--tw-contrast, ) var(--tw-grayscale, ) var(--tw-hue-rotate, ) var(--tw-invert, ) var(--tw-saturate, ) var(--tw-sepia, ) var(--tw-drop-shadow, );
  }

  .backdrop-blur-sm {
    --tw-backdrop-blur: blur(var(--blur-sm));
    -webkit-backdrop-filter: var(--tw-backdrop-blur, ) var(--tw-backdrop-brightness, ) var(--tw-backdrop-contrast, ) var(--tw-backdrop-grayscale, ) var(--tw-backdrop-hue-rotate, ) var(--tw-backdrop-invert, ) var(--tw-backdrop-opacity, ) var(--tw-backdrop-saturate, ) var(--tw-backdrop-sepia, );
    backdrop-filter: var(--tw-backdrop-blur, ) var(--tw-backdrop-brightness, ) var(--tw-backdrop-contrast, ) var(--tw-backdrop-grayscale, ) var(--tw-backdrop-hue-rotate, ) var(--tw-backdrop-invert, ) var(--tw-backdrop-opacity, ) var(--tw-backdrop-saturate, ) var(--tw-backdrop-sepia, );
  }

  .backdrop-filter {
    -webkit-backdrop-filter: var(--tw-backdrop-blur, ) var(--tw-backdrop-brightness, ) var(--tw-backdrop-contrast, ) var(--tw-backdrop-grayscale, ) var(--tw-backdrop-hue-rotate, ) var(--tw-backdrop-invert, ) var(--tw-backdrop-opacity, ) var(--tw-backdrop-saturate, ) var(--tw-backdrop-sepia, );
    backdrop-filter: var(--tw-backdrop-blur, ) var(--tw-backdrop-brightness, ) var(--tw-backdrop-contrast, ) var(--tw-backdrop-grayscale, ) var(--tw-backdrop-hue-rotate, ) var(--tw-backdrop-invert, ) var(--tw-backdrop-opacity, ) var(--tw-backdrop-saturate, ) var(--tw-backdrop-sepia, );
  }

  .transition {
    transition-property: color, background-color, border-color, outline-color, text-decoration-color, fill, stroke, --tw-gradient-from, --tw-gradient-via, --tw-gradient-to, opacity, box-shadow, transform, translate, scale, rotate, filter, -webkit-backdrop-filter, backdrop-filter, display, content-visibility, overlay, pointer-events;
    transition-timing-function: var(--tw-ease, var(--default-transition-timing-function));
    transition-duration: var(--tw-duration, var(--default-transition-duration));
  }

  .transition-all {
    transition-property: all;
    transition-timing-function: var(--tw-ease, var(--default-transition-timing-function));
    transition-duration: var(--tw-duration, var(--default-transition-duration));
  }

  .transition-colors {
    transition-property: color, background-color, border-color, outline-color, text-decoration-color, fill, stroke, --tw-gradient-from, --tw-gradient-via, --tw-gradient-to;
    transition-timing-function: var(--tw-ease, var(--default-transition-timing-function));
    transition-duration: var(--tw-duration, var(--default-transition-duration));
  }

  .transition-opacity {
    transition-property: opacity;
    transition-timing-function: var(--tw-ease, var(--default-transition-timing-function));
    transition-duration: var(--tw-duration, var(--default-transition-duration));
  }

  .duration-300 {
    --tw-duration: var(--transition-duration-300);
    transition-duration: var(--transition-duration-300);
  }

  .ease-in {
    --tw-ease: var(--ease-in);
    transition-timing-function: var(--ease-in);
  }

  .ease-in-out {
    --tw-ease: var(--ease-in-out);
    transition-timing-function: var(--ease-in-out);
  }

  @media (hover: hover) {
    .hover\:opacity-70:hover {
      opacity: .7;
    }
  }

  @media (min-width: 48rem) {
    .md\:mt-0 {
      margin-top: calc(var(--spacing) * 0);
    }

    .md\:block {
      display: block;
    }

    .md\:flex {
      display: flex;
    }

    .md\:hidden {
      display: none;
    }

    .md\:inline {
      display: inline;
    }

    .md\:inline-block {
      display: inline-block;
    }

    .md\:h-30 {
      height: calc(var(--spacing) * 30);
    }

    .md\:flex-none {
      flex: none;
    }

    .md\:grid-cols-3 {
      grid-template-columns: repeat(3, minmax(0, 1fr));
    }

    .md\:flex-row {
      flex-direction: row;
    }

    .md\:gap-6 {
      gap: calc(var(--spacing) * 6);
    }

    .md\:px-16 {
      padding-inline: calc(var(--spacing) * 16);
    }

    .md\:py-4 {
      padding-block: calc(var(--spacing) * 4);
    }

    .md\:text-5xl {
      font-size: var(--text-5xl);
      line-height: var(--tw-leading, var(--text-5xl--line-height));
    }
  }

  @media (min-width: 64rem) {
    .lg\:text-6xl {
      font-size: var(--text-6xl);
      line-height: var(--tw-leading, var(--text-6xl--line-height));
    }
  }
}

.js-new-header[data-state="transparent"] {
  background-color: #0000;
}

.js-new-header[data-state="transparent"] .nav-link, .js-new-header[data-state="transparent"] .ad-bar, .js-new-header[data-state="transparent"] .ad-bar a, .js-new-header[data-state="transparent"] .ad-bar span {
  color: var(--background-color);
}

.js-new-header[data-state="transparent"] .logo-text {
  color: var(--background-color) !important;
}

.js-new-header[data-state="transparent"] .logo-text svg path {
  fill: var(--background-color);
}

.js-new-header[data-state="active"] {
  -webkit-backdrop-filter: blur(.5rem);
  backdrop-filter: blur(.5rem);
  background-color: #fffff6b3;
}

.js-new-header[data-state="active"] .nav-link, .js-new-header[data-state="active"] .ad-bar, .js-new-header[data-state="active"] .ad-bar a, .js-new-header[data-state="active"] .ad-bar span {
  color: var(--primary-color);
}

.js-new-header[data-state="active"] .logo-text {
  color: var(--primary-color) !important;
}

.powered-by-wrapper svg {
  height: calc(var(--spacing) * 4.5);
  width: auto;
  fill: var(--primary-color);
}

.powered-by-wrapper svg path {
  fill: var(--primary-color);
}

.footer-logo-svg svg {
  max-height: inherit;
  width: auto;
  height: auto;
}

.footer-logo-svg svg path {
  fill: var(--primary-color);
}

.promo-marquee-section {
  width: 100%;
}

.promo-marquee-track {
  will-change: transform;
  animation: 30s linear infinite marquee-scroll;
}

@keyframes marquee-scroll {
  0% {
    transform: translateX(0);
  }

  100% {
    transform: translateX(-25%);
  }
}

@media (prefers-reduced-motion: reduce) {
  .promo-marquee-track {
    animation: none;
  }
}

@property --tw-rotate-x {
  syntax: "*";
  inherits: false
}

@property --tw-rotate-y {
  syntax: "*";
  inherits: false
}

@property --tw-rotate-z {
  syntax: "*";
  inherits: false
}

@property --tw-skew-x {
  syntax: "*";
  inherits: false
}

@property --tw-skew-y {
  syntax: "*";
  inherits: false
}

@property --tw-border-style {
  syntax: "*";
  inherits: false;
  initial-value: solid;
}

@property --tw-font-weight {
  syntax: "*";
  inherits: false
}

@property --tw-tracking {
  syntax: "*";
  inherits: false
}

@property --tw-outline-style {
  syntax: "*";
  inherits: false;
  initial-value: solid;
}

@property --tw-blur {
  syntax: "*";
  inherits: false
}

@property --tw-brightness {
  syntax: "*";
  inherits: false
}

@property --tw-contrast {
  syntax: "*";
  inherits: false
}

@property --tw-grayscale {
  syntax: "*";
  inherits: false
}

@property --tw-hue-rotate {
  syntax: "*";
  inherits: false
}

@property --tw-invert {
  syntax: "*";
  inherits: false
}

@property --tw-opacity {
  syntax: "*";
  inherits: false
}

@property --tw-saturate {
  syntax: "*";
  inherits: false
}

@property --tw-sepia {
  syntax: "*";
  inherits: false
}

@property --tw-drop-shadow {
  syntax: "*";
  inherits: false
}

@property --tw-drop-shadow-color {
  syntax: "*";
  inherits: false
}

@property --tw-drop-shadow-alpha {
  syntax: "<percentage>";
  inherits: false;
  initial-value: 100%;
}

@property --tw-drop-shadow-size {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-blur {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-brightness {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-contrast {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-grayscale {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-hue-rotate {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-invert {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-opacity {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-saturate {
  syntax: "*";
  inherits: false
}

@property --tw-backdrop-sepia {
  syntax: "*";
  inherits: false
}

@property --tw-duration {
  syntax: "*";
  inherits: false
}

@property --tw-ease {
  syntax: "*";
  inherits: false
}
