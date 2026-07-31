# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S2, S3, L5, R1, R3, F4, F5, F6, F9

### Invariant Tension Check

**Tensão D1 vs Integração AJAX do Carrinho**: D1 proíbe chamar `LS.*` diretamente em módulos custom. As operações de carrinho (adicionar, remover, atualizar quantidade) são gerenciadas por `store.js.tpl` via jQuery. Resolução: o módulo `cart-drawer.js` NÃO fará operações AJAX. Ele gerenciará apenas a UI do drawer. A sincronização de dados será feita via:
1. **Fetch da página `/cart`** para obter HTML atualizado do carrinho (permitido por D1 — fetch de páginas renderizadas para fins de paginação/conteúdo).
2. **`window.*` callback** definido em `cart-drawer.js` e chamado a partir de `store.js.tpl` após operações AJAX de carrinho para notificar que o carrinho mudou.
3. Operações de quantidade/remoção serão delegadas ao `store.js.tpl` via formulários/links nativos que o legacy já intercepta (`.js-cart-quantity-input`, `.js-item-delete`), ou via um novo `window.*` callback exposto pelo `store.js.tpl`.

**Tensão A9 vs Posicionamento Abaixo do Header**: O drawer usa `data-state="open"|"closed"` seguindo A9. O posicionamento abaixo do header (desktop) será resolvido via CSS (`top` relativo à altura do header usando variável CSS ou cálculo), sem violar nenhum invariante.

Nenhuma violação arquitetural necessária. Todas as tensões são resolvidas dentro dos padrões existentes.

### Risk Level
**MEDIUM**

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

**Não será criado nenhum serviço de dados dedicado.** O carrinho é gerenciado inteiramente pelo `store.js.tpl` (legacy).

**O que será modificado:**
- `static/js/store.js.tpl` — Adicionar chamada a `window.onCartUpdate?.()` no callback `callback_add_to_cart` (após `LS.addToCartEnhanced` sucesso), e após operações de remoção/alteração de quantidade. Este callback é o ponto de sincronização entre o legacy e o custom module.
  - **Por que**: O módulo custom precisa saber quando o carrinho muda para atualizar o drawer. Sem eventos nativos, um `window.*` callback é o mecanismo aprovado (A5, S2).
  - **Constrain**: A5 — comunicação cross-module via `window.*`.

**Mecanismo de carregamento de dados do drawer:**
- O módulo `cart-drawer.js` usará `fetch()` para buscar a página do carrinho (`/cart`) e extrair o HTML dos itens via `DOMParser`. Permitido por D1 (fetch de páginas renderizadas para extração de DOM).

### 2.2 State / Hooks

**O que será criado:**
- `__src/js/modules/system/cart-drawer.js` — Novo módulo com named export `cartDrawerSystem`.
  - **Estado local (closure)**: `isOpen` (boolean) — estado aberto/fechado do drawer.
  - **Guard selector**: `.js-cart-drawer` (A2).
  - **Por que**: O carrinho é um componente global presente em todas as páginas (A1 — contexto `system/`).
  - **Constrain**: A1, A2, A3, F6.

**`window.*` globals a serem registrados (A5, S2):**
- `window.openCartDrawer()` — definido em `cart-drawer.js`. Abre o drawer, ativa o header (`window.setHeaderMenuActive?.(true)`), faz fetch do carrinho atualizado.
- `window.closeCartDrawer()` — definido em `cart-drawer.js`. Fecha o drawer, desativa o header (`window.setHeaderMenuActive?.(false)`).
- `window.onCartUpdate()` — definido em `cart-drawer.js`. Callback chamado pelo `store.js.tpl` após operações AJAX no carrinho. Re-fetcha o conteúdo do carrinho e atualiza o drawer (se aberto) ou o badge do header.

**O que será modificado:**
- `__src/js/index.js` — Adicionar import e invocação de `cartDrawerSystem`. Atualizar contagem de exports: system 7→8, total 14→15.
  - **Constrain**: A3 — named export, agrupado sob comentário `//System`.

### 2.3 UI / Components

**O que será criado:**
- `snipplets/cart/cart-drawer.tpl` — Template do drawer do carrinho.
  - **Constrain**: A10 — organizado em domain folder `cart/`. Criar o diretório `cart/` se não existir.
  - **Estrutura do template:**
    - Container principal: `.js-cart-drawer[data-state="closed"]`
    - Backdrop transparente: `.js-cart-drawer-backdrop` (captura clique fora, sem cor)
    - Painel do drawer: `.js-cart-drawer-panel`
    - Header do drawer: título "Carrinho" + botão fechar (Lucide `x` icon)
    - Lista de itens: `.js-cart-drawer-items` — container scrollável
    - Cada item: imagem, título, variação, preço, controles de quantidade (`-`/input/`+`), botão excluir (Lucide `trash-2` icon)
    - Footer: total + botão CTA "Ir para Checkout" (`{{ store.cart_url | checkout_url }}`)
    - Estado vazio: mensagem quando carrinho está vazio
  - **Ícones**: Todos via `<i data-lucide="...">` (A14, F5). Icons necessários: `x`, `trash-2`, `plus`, `minus`.
  - Os itens do carrinho serão renderizados server-side pelo template usando `{{ cart.items }}`, e atualizados dinamicamente via fetch pelo JS.

**O que será modificado:**
- `snipplets/header/header-new.tpl` — Trocar o `<a href="{{ store.cart_url }}">` do ícone do carrinho por um `<button>` com classe `.js-cart-drawer-toggle` que funciona como trigger do drawer. Manter o fallback `href` para noscript/acessibilidade via `<noscript>` ou progressive enhancement.
  - **Constrain**: R3 — novo `js-*` selector `.js-cart-drawer-toggle` cria contrato binding.
- `layouts/layout.tpl` — Incluir `{% snipplet "cart/cart-drawer.tpl" %}` globalmente, posicionado após o header e antes do `{% template_content %}`.
  - **Constrain**: A10 — inclusão via `{% snipplet %}`.

**Integração com quickbuy:**
- `__src/js/modules/system/item-card-quickbuy.js` — Após a chamada `window.showProductToast?.(...)`, adicionar chamada `window.openCartDrawer?.()` (ou apenas `window.onCartUpdate?.()` para atualizar silenciosamente sem abrir, dependendo da UX desejada). A decisão de abrir o drawer vs apenas atualizar o badge será definida na implementação.
  - **Constrain**: R1, F9 — sem imports horizontais, comunicação via `window.*`.

### 2.4 Styling

**O que será modificado:**
- `__src/css/app.css` — Adicionar bloco de estilos para o cart drawer:
  - `.js-cart-drawer[data-state="closed"]` — drawer oculto (transform: translateX(100%))
  - `.js-cart-drawer[data-state="open"]` — drawer visível (transform: translateX(0))
  - Transição slide da direita para esquerda (consistente com modal drawer)
  - **Desktop**: `position: fixed`, largura ~420px, `right: 0`, `top` calculado baseado na altura do header. Fundo translúcido com `backdrop-filter: blur()` + `color-mix(in srgb, var(--background-color) 85%, transparent)`.
  - **Mobile** (`@media max-width: 767px`): fullscreen (`width: 100%`, `top: 0`, `height: 100vh`), seguindo padrão do modal drawer/filtros.
  - Backdrop transparente: `position: fixed`, `inset: 0`, sem background-color, apenas para capturar cliques.
  - Z-index: Adicionar `--z-cart-drawer` ao `@theme` block, valor entre `--z-toast` (90) e `--z-modal` (100), ex: `95`.
  - **Constrain**: A8, F4 — cores via CSS custom properties, nunca hardcoded. A9 — `data-state` pattern.

### 2.5 Assets

**Nenhum asset novo necessário.** Todos os ícones usam Lucide (já disponível como global). Não há imagens ou fontes adicionais.
- **Constrain**: A14, F5 — Lucide é o sistema canônico de ícones.

---

## 3. Execution Phases

### Phase 1: Infraestrutura (Template + CSS + Módulo base)
1. Criar diretório `snipplets/cart/` se não existir.
2. Criar `snipplets/cart/cart-drawer.tpl` com a estrutura HTML completa do drawer (container com `data-state="closed"`, backdrop, painel, header, lista de itens via `{{ cart.items }}`, footer com total e CTA).
3. Incluir o snipplet em `layouts/layout.tpl`.
4. Adicionar estilos do cart drawer em `__src/css/app.css` (posicionamento, animação slide, responsivo desktop/mobile, backdrop, z-index token).
5. Criar `__src/js/modules/system/cart-drawer.js` com:
   - Guard selector `.js-cart-drawer`
   - Lógica de abrir/fechar (data-state toggle)
   - Integração com header (`window.setHeaderMenuActive?.()`)
   - Registro de `window.openCartDrawer`, `window.closeCartDrawer`
   - Event listeners: click no backdrop fecha, click no botão fechar fecha, Escape fecha
6. Importar `cartDrawerSystem` em `__src/js/index.js`.
7. **Testável**: O drawer abre e fecha visualmente com animação, o header ativa/desativa ao abrir/fechar.

### Phase 2: Integração com Legacy + Dados do Carrinho
1. Modificar `snipplets/header/header-new.tpl` — trocar link do carrinho por trigger `.js-cart-drawer-toggle`.
2. Adicionar no `cart-drawer.js`: listener para `.js-cart-drawer-toggle` que chama `window.openCartDrawer?.()`.
3. Implementar `window.onCartUpdate` em `cart-drawer.js` — usa `fetch('/cart')` + `DOMParser` para extrair HTML atualizado dos itens do carrinho e injetar no drawer. Chama `lucide.createIcons()` após injeção (A6).
4. Modificar `static/js/store.js.tpl` — adicionar `window.onCartUpdate?.()` no `callback_add_to_cart` e após operações de remoção/quantidade.
5. Atualizar badge do header (`.js-cart-widget-amount`) como parte do `onCartUpdate`.
6. **Testável**: Clicar no ícone do carrinho abre o drawer com itens reais. Adicionar produto via formulário de produto atualiza o drawer.

### Phase 3: Interações Internas + Integração Quickbuy
1. Implementar controles de quantidade no drawer — botões +/- e input disparam operações do legacy (via formulários ou chamada delegada ao `store.js.tpl`).
2. Implementar botão excluir item — delega remoção ao `store.js.tpl` e re-fetcha o carrinho.
3. Implementar estado vazio — quando o carrinho fica sem itens, mostrar mensagem.
4. Modificar `item-card-quickbuy.js` — após `window.showProductToast?.(...)`, chamar `window.onCartUpdate?.()` para atualizar o drawer/badge silenciosamente.
5. **Testável**: Alterar quantidade, excluir itens, e adicionar via quickbuy refletem corretamente no drawer.

---

## 4. Risk Controls

### Edge Cases
- **Carrinho vazio**: O drawer deve exibir estado vazio (mensagem "Carrinho vazio") e ocultar o footer com total/CTA.
- **Fetch falha**: Se `fetch('/cart')` falhar (rede, timeout), o drawer deve manter o conteúdo anterior e não mostrar estado quebrado. Considerar retry silencioso.
- **Múltiplos cliques rápidos no toggle**: Debounce na abertura/fechamento para evitar estados intermédios na animação.
- **Adição rápida via quickbuy**: Múltiplas adições em sequência devem encadear corretamente os fetches (cancelar fetch anterior se um novo é disparado).
- **Scroll do body**: No mobile (fullscreen), impedir scroll do body quando drawer está aberto. No desktop, NÃO impedir scroll do body (drawer parcial).
- **Item com variações longas**: Truncar texto de variação com ellipsis para não quebrar layout do item.
- **Preço com desconto**: Garantir que o template exibe preço original riscado + preço com desconto, caso aplicável.
- **Lucide icons após fetch**: Após injetar HTML obtido via fetch no drawer, chamar `lucide.createIcons()` com guard `typeof lucide !== "undefined"` (A6).

### Regression Zones
- **Header behavior**: A ativação do header via `window.setHeaderMenuActive` é compartilhada com o menu mobile. Garantir que abrir o drawer não conflita com o menu mobile (fechar menu se aberto, e vice-versa).
- **Toast system**: O quickbuy mostra toast E atualiza o drawer. Garantir que os z-index não conflitam (toast z=90, cart drawer z=95).
- **Modal system**: Se o modal estiver aberto (z=100), o cart drawer (z=95) ficará atrás. Isso é correto — o modal tem prioridade.
- **`store.js.tpl` callbacks**: A adição de `window.onCartUpdate?.()` ao callback de add-to-cart NÃO deve alterar o fluxo existente (notificação, related products, cross-selling). O call deve ser adicionado no final, após toda a lógica existente.
- **Badge do carrinho**: O `store.js.tpl` já atualiza `.js-cart-widget-amount`. O `onCartUpdate` pode ler esse valor do DOM ou da resposta do fetch. NÃO duplicar a lógica de atualização.

### Strict Non-Modification Areas
- `__src/js/modules/system/modal.js` — NÃO modificar. O cart drawer é independente do modal system.
- `__src/js/modules/system/toast.js` — NÃO modificar (apenas consumir `window.showProductToast`).
- `__src/js/modules/system/header.js` — NÃO modificar (apenas consumir `window.setHeaderMenuActive`).
- `__src/js/modules/system/search.js` — NÃO modificar.
- `__src/js/modules/home/*` — NÃO modificar.
- `__src/js/modules/category/*` — NÃO modificar.
- `config/settings.txt` — NÃO modificar (nenhuma nova setting necessária para esta feature).
- `snipplets/notification/modal.tpl` — NÃO modificar.
- `snipplets/notification/toast.tpl` — NÃO modificar.
- `templates/cart.tpl` — NÃO modificar (a página full do carrinho continua existindo como fallback).
- `esbuild.config.mjs`, `pre-build.js` — NÃO modificar.
