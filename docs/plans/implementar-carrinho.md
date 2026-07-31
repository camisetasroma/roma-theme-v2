# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants

A1, A2, A3, A5, A6, A8, A9, A10, A12, A13, A14, D1, D2, S1, S2, S3, S4, L3, L5, R1, R3, F2, F4, F5, F6, F9

### Invariant Tension Check

**Tensão 1 — Modal Gaius (drawer mode) vs. Drawer dedicado:**
O modal Gaius (`modal.js`) já suporta `mode: "drawer"` com slide-in da direita (420px desktop, 100% mobile). Porém, o body do modal tem `height: calc(100% - 57px)` e `padding: 20px; overflow-y: auto` — estrutura genérica que não suporta o layout do carrinho com **footer fixo** (totais + CTA sticky no bottom). O carrinho exige uma estrutura de 3 zonas: header fixo, corpo scrollável, footer fixo. **Resolução**: O carrinho terá seu próprio drawer dedicado com `data-state` pattern (A9), **não** reutilizará o modal Gaius. Isso evita contaminar o modal genérico com lógica específica do carrinho e permite controle total do layout fixo. O drawer do carrinho terá seu próprio container, overlay e CSS — análogo ao modal mas com propósito específico.

**Tensão 2 — Delegação ao legado vs. controle da UI:**
O `store.js.tpl` gerencia toda a lógica CRUD do carrinho via `LS.*` (jQuery). O módulo custom controla apenas a UI do drawer. A comunicação é bidirecional via `window.*` globals (A5, S2): o custom expõe `window.openCart()` para o legado abrir o drawer após add-to-cart; o legado já re-renderiza o HTML do cart panel via AJAX callbacks. O módulo custom precisa reagir a essas re-renderizações (ex: re-chamar `lucide.createIcons()` após update do HTML — A6). Não há violação arquitetural — é o mesmo padrão de `category-filters.js` delegando ao `window.openModal()`.

**Tensão 3 — Sistema de modais antigo (jQuery) coexistindo:**
O `store.js.tpl` usa `modalOpen('#modal-cart')` para abrir o carrinho via sistema jQuery. A migração precisa substituir essas chamadas por `window.openCart?.()` sem quebrar os outros modais jQuery (`#quickshop-modal`, `#related-products-notification`, `#js-cross-selling-modal`). Apenas o `#modal-cart` será migrado. Os demais permanecem no sistema legado.

### Risk Level

**MEDIUM**

Justificativa: integração bidirecional com `store.js.tpl` (maior ponto de acoplamento do tema), migração parcial de modal jQuery → drawer custom, e superfície de templates significativa. Porém, o padrão de comunicação via `window.*` globals é bem estabelecido e o escopo visual é contido ao drawer.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

Nenhuma camada de dados/serviços será criada. Toda a lógica de CRUD do carrinho (adicionar, remover, alterar quantidade) permanece 100% delegada ao `store.js.tpl` via `LS.*` (D1, L5, F2). O módulo custom não fará fetch de APIs, não acessará `LS.*`, e não persistirá estado local (S4).

Os dados do carrinho serão lidos do DOM via template variables renderizadas pelo servidor Nuvemshop (`{{ cart.items }}`, `{{ cart.total }}`, etc.) e via `data-*` attributes nos elementos HTML (D1).

### 2.2 State / Hooks

**Criar: `__src/js/modules/cart/cart-drawer.js`**
- Named export `cartDrawer` (F6, A3)
- Guard de DOM: `const drawer = document.querySelector('.js-cart-drawer'); if (!drawer) return;` (A2)
- Estado local via closure: `isOpen` (boolean) (S1)
- Controle de abertura/fechamento: manipular `data-state="open"|"closed"` no container `.js-cart-drawer` (A9, S3)
- Controle de scroll lock: salvar e restaurar `document.body.style.overflow` ao abrir/fechar (mesmo padrão do `modal.js`)
- Registrar globals (A5, S2):
  - `window.openCart()` — abre o drawer, seta `data-state="open"`
  - `window.closeCart()` — fecha o drawer, seta `data-state="closed"`
  - `window.refreshCartDrawer()` — chamada após AJAX updates do `store.js.tpl` para re-inicializar Lucide icons (A6) e atualizar event listeners nos novos elementos do DOM
- Event listeners: click no `.js-cart-toggle` (header) para abrir, `.js-cart-drawer-close` e `.js-cart-drawer-overlay` para fechar, `Escape` para fechar
- Após qualquer re-renderização do conteúdo do drawer pelo legado (via `window.refreshCartDrawer()`), chamar `lucide.createIcons()` com guard `typeof lucide !== "undefined"` (A6)

**Criar: `__src/js/modules/cart/cart-recommendations-carousel.js`**
- Named export `cartRecommendationsCarousel` (F6, A3)
- Guard de DOM: `const container = document.querySelector('.js-cart-recommendations'); if (!container) return;` (A2)
- Inicializar Swiper via constructor global `new Swiper()` (L3, F8) no container do carrossel de recomendações dentro do drawer
- Configuração Swiper: `slidesPerView: 2`, `spaceBetween: 12`, pagination dots, navigation arrows — similar ao `product-carousel.js` mas simplificado
- Chamar `lucide.createIcons()` após Swiper inicializar (A6)
- Não importa de `product-carousel.js` (R1, F9)

**Modificar: `__src/js/index.js`**
- Adicionar grupo `//Cart` com imports e invocações dos dois módulos (A3)

### 2.3 UI / Components

**Criar: `snipplets/cart/cart-drawer.tpl`** (A10)
- Container principal do drawer com classes `js-cart-drawer` e `data-state="closed"`
- Estrutura de 3 zonas: header fixo (título + close), corpo scrollável (itens + barras + recomendações), footer fixo (totais + CTA)
- Overlay `.js-cart-drawer-overlay` (fundo escurecido com backdrop blur)
- Header: título "Carrinho" (font heading) + botão fechar com `<i data-lucide="x">` (A14)
- Corpo scrollável: inclui os sub-snipplets abaixo via `{% snipplet %}` (A10)
- Footer fixo: inclui `cart-drawer-totals.tpl`

**Criar: `snipplets/cart/cart-drawer-item.tpl`** (A10)
- Item individual do carrinho renderizado via `{% for item in cart.items %}`
- Layout: imagem, nome, variante, preço, controles de quantidade (botões `<i data-lucide="minus">` e `<i data-lucide="plus">`) (A14)
- Controles de quantidade usam `onclick` delegando a `LS.minusQuantity()` / `LS.plusQuantity()` / `LS.removeItem()` (D2 — delegação ao legado)
- Classes `js-*` para binding: `.js-cart-drawer-items` (container), `[data-item-id]` (cada item)
- Preço usa `{{ item.subtotal }}` com markup para preço original vs. promocional

**Criar: `snipplets/cart/cart-discount-bar.tpl`** (A10)
- Barra de progressão de desconto por quantidade
- Primeiro tenta usar variáveis nativas da plataforma (`{{ cart.promotional_discount.* }}` se disponíveis)
- Fallback via settings: `{{ settings.cart_discount_threshold }}`, `{{ settings.cart_discount_text }}`
- Visibilidade condicional: `{% if settings.cart_discount_enabled %}` ou equivalente plataforma
- Track e fill com classes Tailwind usando tokens do `@theme` (A8, F4)
- Texto configurável via settings (A13)

**Criar: `snipplets/cart/cart-free-shipping-bar.tpl`** (A10)
- Barra de progressão para frete grátis
- Primeiro tenta usar `{{ cart.free_shipping.min_price_free_shipping }}` (plataforma nativa)
- Fallback via settings: `{{ settings.cart_free_shipping_value }}`, `{{ settings.cart_free_shipping_text }}`
- Mesma estrutura visual da discount bar: track + fill + texto
- Cores via tokens do `@theme` (A8, F4)

**Criar: `snipplets/cart/cart-recommendations.tpl`** (A10)
- Seção "Aproveite o envio" com carrossel Swiper
- Título (font heading) + container Swiper `.js-cart-recommendations`
- Cada slide: imagem do produto, seletor de tamanho (se aplicável), botão add, nome, preço
- Pagination dots + setas prev/next com `<i data-lucide="chevron-left">` / `<i data-lucide="chevron-right">` (A14)
- Produtos renderizados via template variables de seção ou cross-selling da plataforma

**Criar: `snipplets/cart/cart-important-message.tpl`** (A10)
- Bloco de mensagem emergencial configurável via settings
- `hidden` por padrão (S3 — mecanismo 1)
- Visibilidade controlada por `{% if settings.cart_important_message_enabled %}`
- Conteúdo de `{{ settings.cart_important_message_text }}`

**Criar: `snipplets/cart/cart-drawer-totals.tpl`** (A10)
- Bloco de totais fixo no bottom do drawer
- Valor total: `{{ cart.total }}` com `data-priceraw`
- Parcelamento: usar `{{ component('installments', ...) }}` (plataforma)
- Desconto no Pix: usar `{{ component('payment-discount-price', ...) }}` se disponível
- Botão CTA "Ir para o Checkout": `<a>` ou `<form>` apontando para checkout
- Cores e tipografia via tokens `@theme` (A8, F4)

**Modificar: `snipplets/header/header-new.tpl`**
- Trocar o `<a href="{{ store.cart_url }}">` do carrinho por `<button type="button" class="js-cart-toggle ...">` (R3)
- Manter o ícone `<i data-lucide="shopping-cart">` e o counter `.js-cart-widget-amount`
- O botão dispara a abertura do drawer via event listener no módulo `cart-drawer.js`

**Modificar: `layouts/layout.tpl`**
- Adicionar `{% snipplet "cart/cart-drawer.tpl" %}` após o modal Gaius e antes do `{% template_content %}` (A10)
- Posicionamento análogo ao toast e modal containers

**Modificar: `static/js/store.js.tpl`**
- No `callback_add_to_cart`: quando `cart_open_type === 'show_cart'`, substituir `modalOpen('#modal-cart', 'openFullScreenWithoutClick')` por `window.openCart?.()` (A5, S2)
- Após AJAX updates de quantidade/remoção que re-renderizam o cart panel, adicionar `window.refreshCartDrawer?.()` para o módulo custom re-inicializar ícones e listeners
- Manter todos os outros modais jQuery (`#quickshop-modal`, `#related-products-notification`, `#js-cross-selling-modal`) inalterados

### 2.4 Styling

**Modificar: `__src/css/app.css`**

Adicionar seção de estilos do cart drawer após a seção do modal Gaius, seguindo o padrão `data-state` (A9):

- `.js-cart-drawer[data-state="closed"]` — `opacity: 0; pointer-events: none; visibility: hidden;`
- `.js-cart-drawer[data-state="open"]` — `opacity: 1; pointer-events: auto; visibility: visible;`
- `.js-cart-drawer-panel` — drawer panel fixo à direita com `position: fixed; top: 0; right: 0; bottom: 0; width: 100%; max-width: 100%;` (mobile) e `max-width: 420px` via `@media (min-width: 768px)` (desktop). Transição `transform: translateX(100%)` → `translateX(0)` (análogo ao modal drawer)
- `.js-cart-drawer-overlay` — overlay com `background: rgb(0 0 0 / 0.3); backdrop-filter: blur(4px);` (mesmo padrão do modal overlay — usando rgba(0,0,0) que é permitido por A8)
- Layout de 3 zonas via CSS: header `flex-none`, corpo `flex-1 overflow-y-auto`, footer `flex-none` — usando flexbox com `flex-direction: column; height: 100%`
- z-index: usar um novo token `--z-cart-drawer` no `@theme` block, valor acima do header mas abaixo ou igual ao modal (ex: `95`)
- Barras de progresso: track com `bg-black/10` (permitido, é overlay semi-transparente), fill com cor temática via CSS custom property
- Transições suaves de 300ms para abertura/fechamento, consistente com o modal Gaius

Todas as cores DEVEM usar tokens `@theme` ou CSS custom properties da plataforma (A8, F4). Nenhum hex/rgba temático será hardcodado.

### 2.5 Assets

Nenhum novo asset estático necessário. Todos os ícones via Lucide (A14): `x`, `minus`, `plus`, `chevron-left`, `chevron-right`, `shopping-cart`, `trash-2`. Todos já existem na biblioteca Lucide — nenhum SVG snipplet novo será criado (F5).

---

## 3. Execution Phases

### Phase 1: Infraestrutura do Drawer (fundação)

1. Criar `snipplets/cart/cart-drawer.tpl` com estrutura de 3 zonas (header, corpo vazio, footer placeholder) e `data-state="closed"`
2. Adicionar inclusão do drawer em `layouts/layout.tpl`
3. Adicionar estilos do drawer em `__src/css/app.css` (container, overlay, panel, transições, z-index token)
4. Criar `__src/js/modules/cart/cart-drawer.js` com lógica de abrir/fechar e registrar `window.openCart()` / `window.closeCart()`
5. Modificar `__src/js/index.js` para importar e invocar `cartDrawer` no grupo `//Cart`
6. Modificar `snipplets/header/header-new.tpl` para trocar `<a>` do carrinho por `<button class="js-cart-toggle">`

**Testável**: o drawer abre e fecha ao clicar no ícone do carrinho no header, com animação e overlay.

### Phase 2: Conteúdo do Carrinho (itens, totais, barras)

1. Criar `snipplets/cart/cart-drawer-item.tpl` com layout de item (imagem, nome, preço, qty controls)
2. Criar `snipplets/cart/cart-drawer-totals.tpl` com total, parcelamento, pix, CTA
3. Criar `snipplets/cart/cart-discount-bar.tpl` com barra de desconto
4. Criar `snipplets/cart/cart-free-shipping-bar.tpl` com barra de frete grátis
5. Criar `snipplets/cart/cart-important-message.tpl` com mensagem configurável
6. Integrar todos os sub-snipplets no corpo e footer do `cart-drawer.tpl`
7. Adicionar settings necessários em `config/settings.txt` (cart_discount_*, cart_free_shipping_*, cart_important_message_*)
8. Adicionar `window.refreshCartDrawer()` no `cart-drawer.js` para re-inicializar Lucide e listeners após updates AJAX
9. Modificar `static/js/store.js.tpl` para substituir `modalOpen('#modal-cart')` por `window.openCart?.()` e adicionar chamadas a `window.refreshCartDrawer?.()` nos callbacks de qty/remove

**Testável**: o drawer mostra itens do carrinho, permite alterar quantidade, exibe totais e barras de progresso, navega para checkout.

### Phase 3: Carrossel de Recomendações e Polimento

1. Criar `snipplets/cart/cart-recommendations.tpl` com carrossel Swiper
2. Criar `__src/js/modules/cart/cart-recommendations-carousel.js` com inicialização Swiper
3. Importar e invocar `cartRecommendationsCarousel` em `__src/js/index.js`
4. Integrar o snipplet de recomendações no corpo do `cart-drawer.tpl`
5. Garantir que `lucide.createIcons()` é chamado após inicialização do Swiper e após qualquer re-renderização (A6)
6. Polimento visual: ajustar espaçamentos, tipografia, responsividade mobile/desktop

**Testável**: carrossel de recomendações funciona dentro do drawer com navegação, ícones renderizados corretamente, drawer completo e funcional em mobile e desktop.

---

## 4. Risk Controls

### Edge Cases

1. **Carrinho vazio**: o drawer deve exibir estado vazio (mensagem + CTA para continuar comprando) quando `{{ cart.items_count == 0 }}`
2. **Muitos itens**: o corpo scrollável deve manter scroll independente sem afetar o header/footer fixos do drawer
3. **Update AJAX racing**: se o usuário clica rapidamente em +/- quantidade, o `store.js.tpl` enfileira chamadas AJAX. O `window.refreshCartDrawer()` pode ser chamado múltiplas vezes — deve ser idempotente (chamar `lucide.createIcons()` é naturalmente idempotente)
4. **JS desabilitado**: o `<button class="js-cart-toggle">` não funcionará. O `templates/cart.tpl` (página de carrinho) continua existindo como fallback. Considerar adicionar `<noscript>` link ou manter `href` no botão
5. **Drawer aberto + resize**: transição mobile ↔ desktop enquanto drawer está aberto deve adaptar o max-width sem flash visual
6. **Foco e acessibilidade**: ao abrir o drawer, o foco deve ir para o drawer; ao fechar, voltar ao trigger. ESC fecha o drawer
7. **Produtos sem variantes**: o carrossel de recomendações deve lidar com produtos que não têm seletor de tamanho
8. **Promoções nativas indisponíveis**: os templates das barras de progresso devem degradar graciosamente se as variáveis de template da plataforma não existirem, usando fallback de settings

### Regression Zones

1. **`store.js.tpl` callbacks**: a substituição de `modalOpen('#modal-cart')` por `window.openCart?.()` é o ponto mais crítico. Se o `window.openCart` não estiver registrado (ex: erro no bundle, falha de carregamento), o optional chaining previne crash mas o carrinho não abrirá. Manter o `templates/cart.tpl` funcional como rede de segurança
2. **Outros modais jQuery**: `#quickshop-modal`, `#related-products-notification`, `#js-cross-selling-modal` NÃO devem ser afetados. Verificar que nenhuma alteração no `store.js.tpl` interfira com esses fluxos
3. **Counter do header** (`.js-cart-widget-amount`): o legacy `callback_add_to_cart` anima esse elemento. A troca de `<a>` para `<button>` no header NÃO deve alterar a classe `.js-cart-widget-amount` — manter inalterada
4. **Cross-selling e notification-cart**: esses fluxos permanecem no sistema jQuery legado. Verificar que continuam funcionando após as alterações no `store.js.tpl`
5. **Notification flow**: quando `cart_open_type === 'show_notification'`, o fluxo de notificação flutuante (`.js-alert-added-to-cart`) NÃO deve ser alterado

### Strict Non-Modification Areas

1. **`__src/js/modules/system/modal.js`** — o modal Gaius NÃO será modificado. O carrinho terá drawer dedicado
2. **`__src/js/modules/system/toast.js`** — sistema de toasts inalterado
3. **`__src/js/modules/system/header.js`** — lógica de animação do header inalterada
4. **`__src/js/modules/system/menu.js`** — menu mobile inalterado
5. **`__src/js/modules/system/search.js`** — search overlay inalterado
6. **`__src/js/modules/home/*`** — módulos da home inalterados
7. **`__src/js/modules/category/*`** — módulos de categoria inalterados
8. **`snipplets/notification/modal.tpl`** — template do modal Gaius inalterado
9. **`snipplets/notification/toast.tpl`** — template de toast inalterado
10. **`snipplets/notification-cart.tpl`** — notificação de "adicionado ao carrinho" flutuante permanece no sistema legado
11. **`templates/cart.tpl`** — página de carrinho completa permanece como fallback para JS desabilitado
12. **`esbuild.config.mjs`** e **`pre-build.js`** — build system inalterado
13. **Todos os modais jQuery** exceto `#modal-cart` — quickshop, cross-selling, recommendations permanecem inalterados
