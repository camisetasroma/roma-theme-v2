# Roma Theme V2 - Guia Completo do Projeto

> Documento de referencia para desenvolvimento. Consulte antes de implementar qualquer funcionalidade.

---

## Filosofia de Desenvolvimento

- **Sempre preferir codigo customizado** em `__src/` ao inves de editar o legado em `store.js.tpl`.
- Se precisar usar a API da Nuvemshop, criar estrutura simples em `store.js.tpl` para facilitar manutencao.
- O `store.js.tpl` contem codigo legado mal escrito/otimizado. Usamos ele como referencia para entender o que ja existe, e **sempre reescrevemos melhor** em `__src/js/modules/`.
- Tailwind CSS v4 (sem tailwind.config.js, usa `@theme` direto no CSS).
- Referencia Tailwind: https://tailwindcss.com/docs/installation/using-postcss

---

## Estrutura de Diretorios

```
roma-theme-v2/
├── __src/                    # CODIGO FONTE (pre-build) - ONDE DESENVOLVEMOS
│   ├── css/
│   │   └── app.css           # Tailwind + estilos customizados
│   └── js/
│       ├── index.js          # Entry point (importa todos os modulos)
│       └── modules/
│           ├── home/         # Modulos especificos da home
│           └── system/       # Modulos globais (header, menu, modal, toast)
├── config/                   # Configuracoes do tema Nuvemshop
│   ├── settings.txt          # Todas as opcoes de customizacao (1449 linhas)
│   ├── sections.txt          # Secoes de produtos (primary, carousel tabs)
│   ├── defaults.txt          # Valores padrao
│   ├── translations.txt      # Traducoes multi-idioma
│   ├── variants.txt          # Variantes do tema
│   └── data.json             # Metadata de assets compilados
├── layouts/
│   └── layout.tpl            # Template master (head, body, scripts)
├── templates/                # Templates de pagina
│   ├── home.tpl              # Homepage
│   ├── product.tpl           # Pagina de produto
│   ├── category.tpl          # Listagem de categoria
│   ├── cart.tpl              # Carrinho
│   ├── search.tpl            # Busca
│   ├── contact.tpl           # Contato
│   ├── blog.tpl / blog-post.tpl
│   ├── page.tpl              # Paginas estaticas
│   ├── password.tpl          # Loja protegida
│   ├── 404.tpl
│   └── account/              # Area do cliente (login, registro, pedidos, enderecos)
├── snipplets/                # Componentes reutilizaveis (~143 arquivos)
│   ├── header/               # Cabecalho (header-new, advertising, search, utilities)
│   ├── home/                 # Secoes da home (hero, marquee, carousel, grid, faq, etc)
│   ├── navigation/           # Menu mobile e desktop, accordion, dropdown
│   ├── notification/         # Modal e toast containers
│   ├── grid/                 # Listagem de produtos (item, filtros, paginacao, quick-shop)
│   ├── product/              # Componentes de produto (form, imagem, variantes)
│   ├── cart/                 # Painel do carrinho (cart-panel, item-ajax, totals)
│   ├── shipping/             # Calculadora de frete
│   ├── forms/                # Componentes de formulario
│   ├── svg/                  # 55 templates de icones SVG (Lagado! sempre usar o lucid)
│   ├── social/               # Links e compartilhamento social
│   ├── banner-services/      # Banners de servico (frete, seguranca, etc)
│   ├── defaults/             # Templates de ajuda/placeholder
│   └── (footer, breadcrumbs, newsletter, whatsapp, etc)
├── static/                   # Assets compilados (OUTPUT)
│   ├── css/
│   │   ├── app.tpl           # Tailwind compilado (output do build)
│   │   ├── style-colors.scss.tpl   # Cores dinamicas do tema
│   │   ├── style-critical.tpl      # CSS critico (inline no head)
│   │   └── style-async.scss.tpl    # CSS async (nao-critico)
│   ├── js/
│   │   ├── gaius-vXX.js     # BUNDLE Versionado por causa do cache do nuvemshop (output do esbuild)
│   │   ├── store.js.tpl      # Funcoes legado da Nuvemshop (jQuery)
│   │   ├── external.js.tpl   # Libs externas (com jQuery)
│   │   ├── external-no-dependencies.js.tpl  # Libs externas (sem jQuery)
│   │   ├── lucide.min.js     # Biblioteca de icones
│   │   └── instatheme.js     # Integracao Instagram
│   └── images/
│       └── empty-placeholder.png
├── esbuild.config.mjs        # Config do bundler JS
└── package.json              # Dependencies e scripts
```

---

## Build System

### Comandos

```bash
npm run dev          # Watch CSS + JS simultaneo (desenvolvimento)
npm run watch:css    # Tailwind watch → static/css/app.tpl
npm run build:css    # Tailwind build (producao)
npm run watch:js     # esbuild watch → static/js/gaius-vXX.js
npm run build:js     # esbuild build (producao)
```

### Pipeline CSS

**Input:** `__src/css/app.css` → **Processo:** Tailwind CLI v4 (`--optimize`) → **Output:** `static/css/app.tpl`

### Pipeline JS

**Input:** `__src/js/index.js` → **Processo:** esbuild (bundle, minify, ES2018, IIFE) → **Output:** `static/js/gaius-vXX.js`

### Dependencias

- `tailwindcss@^4.1.18` + `@tailwindcss/cli@^4.1.18`
- `esbuild@0.27.2`
- `concurrently@^9.2.1`

---

## Arquitetura CSS (`__src/css/app.css`)

### Sistema de Cores (Tailwind v4 @theme)

```css
--color-bg: var(--background-color)        /* Fundo */
--color-fg: var(--primary-color)           /* Primario/Foreground */
--color-secondary: var(--text-color)       /* Texto */
--color-bg-subtle: mix(primary 5% + bg 95%)
--color-fg-muted: mix(primary 60% + bg 40%)
```

As variaveis `--background-color`, `--primary-color`, `--text-color` vem do `style-colors.scss.tpl` (gerado pelo admin da Nuvemshop).

### Tipografia

- `--font-heading`: Fonte de titulos/banners
- `--font-sans`: Fonte de corpo
- Tamanhos: xs (12px) a 6xl (60px)

### CSS Customizado (onde Tailwind nao resolve)

- Animacao do header (transparent → active)
- Animacao marquee (keyframe `marquee-scroll`)
- Accordion icons do menu
- Scrollbar customizado do carousel de categorias
- Modal overlay e container
- Toast positioning e animacoes
- Ajustes responsivos mobile

---

## Arquitetura JavaScript (`__src/js/`)

### Entry Point (`index.js`)

```javascript
// Modulos globais (carregam em todas as paginas)
import { advertisingCarousel, headerAnimations } from "./modules/system/header";
import { menuSystem } from "./modules/system/menu";
import { modalSystem } from "./modules/system/modals";
import { toastSystem } from "./modules/system/toasts";

headerAnimations();
advertisingCarousel();
menuSystem();
modalSystem();
toastSystem();

// Modulos da home (carregam em todas as paginas, verificam existencia internamente)
import { heroBanner2Carousel } from "./modules/home/hero-banner-2-carousel";
import { productCarousel } from "./modules/home/product-carousel";
import { welcomeCouponToast } from "./modules/home/welcome-coupon-toast";

welcomeCouponToast();
productCarousel();
heroBanner2Carousel();
```

### Modulos do Sistema (`modules/system/`)

| Modulo | Linhas | Funcao |
|--------|--------|--------|
| `header.js` | 68 | Animacao do header no scroll (transparent/active), carousel da barra de anuncios (4s intervalo) |
| `menu.js` | 236 | Menu mobile (tabs, accordion, scroll lock, scrollbar customizado), menu desktop (dropdown, carousel de categorias) |
| `modals.js` | 70 | Sistema de modal com overlay. APIs globais: `window.openModal()`, `window.closeModal()`. Fecha com ESC, click no overlay |
| `toasts.js` | 174 | Sistema de toast notifications. APIs globais: `window.showToast()`, `window.closeToast()`, `window.closeAllToasts()`. Max 4 visiveis, swipe-to-dismiss, auto-dismiss, callbacks |

### Modulos da Home (`modules/home/`)

| Modulo | Linhas | Funcao |
|--------|--------|--------|
| `hero-banner-2-carousel.js` | 143 | Carousel manual do hero banner 2. Seed pagination com cores dinamicas por slide, auto-play 6s, botoes prev/next |
| `product-carousel.js` | 254 | Carousel de produtos com 3 tabs (Swiper.js). Seed pagination customizada, dropdown de tabs, responsivo (2.25→4.25 slides), loop com duplicacao de slides |
| `welcome-coupon-toast.js` | 60 | Toast de cupom de boas-vindas. Exibe 1x (localStorage), delay 1.5s, botao copiar com clipboard API + fallback |

### APIs Globais JavaScript

```javascript
// Modals
window.openModal(content)      // content: HTML string ou elemento DOM
window.closeModal()

// Toasts
window.showToast({ content, duration, onClose, onReady })
window.closeToast(toastElement)
window.closeAllToasts()

// Header
window.setHeaderMenuActive()   // Forca estado ativo do header (usado pelo menu)
```

---

## Hierarquia de Templates

### Fluxo Principal

```
layout.tpl (Master)
  ├── <head> (meta, fonts, CSS inline, scripts)
  ├── header/header-new.tpl (Cabecalho fixo)
  ├── {% template_content %} → templates/*.tpl (Conteudo da pagina)
  ├── notification/modal.tpl (Container de modais)
  ├── notification/toast.tpl (Container de toasts)
  ├── grid/quick-shop.tpl (Modal de compra rapida)
  ├── whatsapp-chat.tpl (Botao flutuante)
  ├── footer.tpl (Rodape)
  └── Scripts (external.js, store.js.tpl, gaius.js, lucide)
```

### Homepage - Sistema de Secoes

A home usa um **router de secoes** (`home-section-switch.tpl`) controlado por `settings.home_order_position_0` ate `home_order_position_12`. Cada posicao carrega uma secao:

| Chave | Snipplet | Descricao |
|-------|----------|-----------|
| `promo_marquee` | `home-promo-marquee.tpl` | Barra de texto rolante |
| `hero_banner` | `home-hero-banner.tpl` | Banner hero estatico |
| `hero_banner_2` | `home-hero-banner-2.tpl` | Banner hero com carousel (2+ slides) |
| `slider` | `home-slider.tpl` | Carousel de imagens |
| `welcome` | `home-welcome-message.tpl` | Mensagem de boas-vindas |
| `products` | `home-featured-products.tpl` | Produtos em destaque |
| `informatives` | `banner-services.tpl` | Banners de servico |
| `categories` | `home-banners.tpl` | Banners de categoria |
| `modules` | `home-modules.tpl` | Modulos imagem + texto |
| `video` | `home-video.tpl` | Video embed |
| `product_carousel` | `home-product-carousel.tpl` | Carousel de produtos (3 tabs) |
| `product_grid` | `home-product-grid.tpl` | Grid 2x2 de produtos |
| `vip_group` | `home-vip-group.tpl` | Banner grupo VIP |
| `faq` | `home-faq.tpl` | FAQ accordion |
| `instafeed` | `home-instafeed.tpl` | Feed Instagram |
| `popup` | `home-popup.tpl` | Popup promocional |

---

## Configuracoes do Tema (`config/settings.txt`)

### Principais Grupos de Configuracao

**Cores e Tipografia:**
- `primary_color`, `accent_color`, `text_color`, `text_muted_color`, `background_color`
- `font_headings`, `font_rest` (155+ Google Fonts disponiveis)

**Header:**
- `head_background` (light/dark), `head_transparent`, `head_fix` (sticky)
- `ad_bar` + `ad_text_1/2/3` + `ad_url_1/2/3` (barra de anuncios rotativa)

**Logos:**
- `logo_inactive_svg` / `logo_inactive`: Logo menu fechado
- `logo_active_svg` / `logo_active`: Logo menu aberto
- `logo_footer_svg` / `logo_footer`: Logo rodape

**Menu:**
- `menu_principal`: Menu ativo
- `menu_highlighted_items`: Itens destacados (vermelho)
- `menu_category_01..06`: Carousel de categorias (imagem, titulo, botao, link)

**Homepage (cada secao tem suas configs):**
- `promo_marquee_text_1..4`, cores
- Hero banners: imagem desktop/mobile, titulo, subtitulo, botao, cor do texto
- `product_carousel_title`, `product_carousel_tab_1/2/3_label`, `product_carousel_bg`
- `product_grid_title`, `product_grid_bg`
- FAQ: `faq_title`, `faq_question_1..6`, `faq_answer_1..6`
- VIP: `vip_group_bg`, titulo, subtitulo, `vip_group_custom_html`, botao

**Listagem de Produtos:**
- `grid_columns`: 1 (3 desktop) ou 2 (4 desktop)
- `product_color_variants`, `product_hover`, `product_item_slider`
- `quick_shop`: Modal de compra rapida

**Carrinho:**
- `ajax_cart`: Adicionar via AJAX
- `cart_open_type`: Notificacao vs abrir carrinho
- `cart_minimum_value`: Valor minimo de compra

**Secoes de Produtos (`config/sections.txt`):**
- `primary`: Produtos em destaque (ate 40)
- `carousel_tab_1/2/3`: Tabs do carousel (ate 40 cada)

---

## Padroes Nuvemshop (Templates .tpl)

### Variaveis Globais Disponiveis

```twig
{{ store.name }}                    {# Nome da loja #}
{{ store.url }}                     {# URL da loja #}
{{ settings.NOME_CONFIG }}          {# Qualquer config do settings.txt #}
{{ customer }}                      {# Cliente logado (ou null) #}
{{ cart.subtotal }}                  {# Subtotal do carrinho #}
{{ cart.free_shipping }}             {# Config frete gratis #}
{{ template }}                      {# Nome do template atual ("home", "product", etc) #}
{{ sections.NOME }}                 {# Secao de produtos #}
{{ menus.NOME }}                    {# Menus configurados #}
{{ languages }}                     {# Idiomas disponiveis #}
{{ pages }}                         {# Paginas do site #}
```

### Filtros e Funcoes

```twig
{{ 'arquivo.js' | static_url }}         {# URL de asset estatico #}
{{ 'style.css' | static_inline }}       {# Inline de asset #}
{{ 'URL' | script_tag }}                {# Wrap em <script> #}
{{ 'URL' | script_tag(true) }}          {# Script async #}
{{ 'texto' | translate }}               {# Traducao #}
{{ 'texto' | escape('js') }}            {# Escape para JS #}
{{ valor | setting_url }}               {# Processar URL de config #}
{{ html | raw }}                        {# HTML sem escape #}
{{ imagem | has_custom_image }}         {# Verificar imagem custom #}
{{ fonte | google_fonts_url }}          {# URL do Google Fonts #}
```

### Includes

```twig
{% snipplet 'header/header-new.tpl' %}                    {# Incluir snipplet #}
{% snipplet 'file.tpl' with { variavel: valor } %}        {# Com variaveis #}
{% template_content %}                                     {# Conteudo da pagina #}
{% head_content %}                                         {# JS/meta da Nuvemshop #}
{{ back_to_admin }}                                        {# Barra admin #}
{{ component('nome') }}                                    {# Componente Nuvemshop #}
{{ component('nome', { opcao: valor }) }}                  {# Com opcoes #}
```

---

## store.js.tpl - Funcionalidades Legado

> **IMPORTANTE:** Este arquivo contem codigo legado jQuery. Ao criar funcionalidades novas, **sempre preferir** criar modulos em `__src/js/modules/`. Use o store.js.tpl apenas como referencia para entender funcionalidades existentes ou quando precisar integrar com APIs da Nuvemshop que dependam de jQuery.

### Funcionalidades Principais

| Area | O que faz |
|------|-----------|
| **Lazy Load** | lazySizes config e event listeners |
| **Notificacoes** | Close handlers, cart notification, cookie banner |
| **Modais (legado)** | Quick shop, full-screen modal, URL hash management |
| **Tabs** | Tab switching logic |
| **Header/Nav** | Navigation handlers, search suggestions |
| **Sliders** | Home image carousel, banner services carousel |
| **Social** | YouTube/Vimeo embed, Facebook login |
| **Grid de Produtos** | Filtros, slider por item, infinite scroll, variantes de cor |
| **Produto** | Parcelas, troca de variante, labels, slider de imagem, quantidade |
| **Carrinho** | Toggle painel, add/update AJAX, esvaziar, recomendacoes |
| **Frete** | Calculadora, barra frete gratis, selecao de opcao, branches |
| **Forms** | Validacao e submit |

---

## Ordem de Carregamento de Scripts

```
1. CSS Critico (inline no <head>)     → style-critical.tpl + app.tpl + style-colors.scss.tpl
2. CSS Async                          → style-async.scss.tpl (carrega como print, troca para all)
3. jQuery (async, condicional)
4. external-no-dependencies.js.tpl    → Libs sem jQuery
5. LS.ready.then(() => {              → Wrapper da Nuvemshop (garante jQuery)
     external.js.tpl                  → Libs com jQuery
     store.js.tpl                     → Funcoes legado
   })
6. gaius-vXX.js                       → Bundle customizado (nosso codigo)
7. lucide.createIcons()               → Inicializacao de icones
8. Custom JS do admin                 → Codigo personalizado via painel
```

---

## Convencoes e Boas Praticas

1. **Novos modulos JS** sempre em `__src/js/modules/` organizados por contexto (`home/`, `system/`, etc).
2. **Importar e chamar** no `__src/js/index.js`.
3. **Verificar existencia do elemento** dentro do modulo antes de executar logica.
4. **APIs globais** via `window.` quando precisar expor funcionalidade para templates ou outros scripts.
5. **Lucide icons** precisam de `lucide.createIcons()` apos inserir HTML dinamicamente.
6. **CSS customizado** vai no `__src/css/app.css` usando classes Tailwind ou CSS puro quando necessario.
7. **Versionamento do bundle:** O arquivo de saida JS segue nomenclatura `gaius-vXX.js`. Ao criar nova versao, atualizar referencia no `esbuild.config.mjs` e no `layout.tpl`.
8. **Nunca editar** `static/css/app.tpl` ou `static/js/gaius-vXX.js` diretamente - sao outputs do build.
9. **Configs novas** no `config/settings.txt` seguem o padrao existente de categorias e tipos.
10. **Templates** usam Twig com extensoes da Nuvemshop. Testar sempre no preview antes de publicar.
