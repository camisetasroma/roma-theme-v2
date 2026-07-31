# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Implementar um carrinho de compras como drawer lateral, substituindo a navegação direta para a página `/cart`. O drawer deve:

- **Desktop**: Drawer lateral direito, posicionado abaixo do header, com fundo translúcido igual ao header. Sem backdrop escuro (backdrop transparente para capturar clique fora). Ao abrir, ativa o header (`data-state="active"`); ao fechar, desativa.
- **Mobile**: Tela inteira, seguindo o mesmo padrão do drawer de filtros da categoria (modal fullscreen).
- **Conteúdo do drawer**: Lista de itens do carrinho com: foto, título, variação, preço, controles de quantidade (-/input/+), botão de excluir (canto superior direito do item).
- **Ação principal**: Botão "Ir para Checkout" que redireciona para o checkout do Nuvemshop.
- **Integração com quickbuy**: O fluxo de compra rápida (`item-card-quickbuy.js`) deve integrar com o carrinho — ao adicionar um item, o carrinho deve refletir a atualização.
- **Animação**: Abrir/fechar com transição slide (similar ao modal drawer e filtros mobile).

## 2. Assumptions (if any)

1. **Header activation**: "Ativará o header" ao abrir o drawer significa chamar `window.setHeaderMenuActive?.(true)` para forçar `data-state="active"`, e `window.setHeaderMenuActive?.(false)` ao fechar — reutilizando o mecanismo existente do header.
2. **Posicionamento abaixo do header (desktop)**: O drawer inicia visualmente abaixo do header. Isso implica que o drawer NÃO é um overlay `position: fixed; top: 0` fullscreen como o modal atual. Precisa de um `top` dinâmico baseado na altura do header, ou estar dentro do fluxo do header.
3. **Transparência translúcida do header**: O fundo do drawer desktop usa o mesmo tratamento visual do header ativo (provavelmente `backdrop-filter: blur()` + fundo semi-transparente via CSS custom properties).
4. **Backdrop transparente**: O backdrop para fechar ao clicar fora é um overlay invisível (sem cor), apenas para capturar eventos de clique. Diferente do modal atual que tem overlay com opacidade.
5. **O drawer será um módulo novo** (`cart-drawer.js`) e NÃO reutilizará o `modal.js` diretamente, dado que o comportamento difere significativamente do modal existente (posição abaixo do header, integração com estado do header, backdrop transparente, sem scroll lock no body para desktop).
6. **Atualização do carrinho após quickbuy**: O quickbuy atualmente faz POST via `store.js.tpl` (legacy). A atualização do drawer após adicionar ao carrinho provavelmente requer observar mudanças no DOM do carrinho (via `MutationObserver` ou eventos do legacy `store.js.tpl`) ou recarregar o conteúdo do drawer via fetch da página do carrinho.
7. **O link do header** que hoje aponta para `{{ store.cart_url }}` será convertido em um trigger que abre/fecha o drawer.
8. **A estrutura HTML dos itens** será nova (não reutilizará `cart-item-ajax.tpl` diretamente), dado que o layout descrito (foto ao lado, botão excluir no canto superior direito) difere do template existente.

## 3. Affected Architectural Domains

| Domain | Impact |
|--------|--------|
| **Template Layer** | Novo snipplet para o drawer do carrinho; modificação do header template para trocar link por trigger |
| **JS Module Layer** | Novo módulo `__src/js/modules/system/cart-drawer.js`; modificação de `index.js` para importar; possível modificação de `item-card-quickbuy.js` para integração |
| **CSS Layer** | Novos estilos em `app.css` para o cart drawer (posição, animação, backdrop, responsivo) |
| **Cross-module Communication** | Novos `window.*` globals para abrir/fechar o carrinho (consumidos pelo quickbuy e header) |
| **Legacy JS Boundary** | Integração com `store.js.tpl` para operações AJAX do carrinho (add/remove/update quantity) |
| **Snipplet Organization** | Novo snipplet domain ou snipplet em domain existente (possivelmente `snipplets/cart/` que já existe como diretório implícito via `cart-panel.tpl` flat file) |
| **Layout** | `layout.tpl` precisará incluir o snipplet do cart drawer globalmente |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A12, A14, D1, S2, S3, L5, R1, R3, F4, F5, F6, F9

## 5. Invariant Impact Explanation

| Invariant | Impact |
|-----------|--------|
| **A1** | Novo módulo DEVE ser criado em `__src/js/modules/system/cart-drawer.js`. O diretório `system/` é correto pois o carrinho é global (todas as páginas). |
| **A2** | O módulo DEVE guardar execução com `const drawer = document.querySelector('.js-cart-drawer'); if (!drawer) return;` como primeira instrução. O guard selector `.js-cart-drawer` já está pré-registrado no contrato. |
| **A3** | DEVE exportar `cartDrawerSystem` como named export. `index.js` DEVE importar e invocar. O contador de exports DEVE ser atualizado de 14 para 15 (system: 7→8). |
| **A5** | Novos `window.*` globals serão necessários (ex: `window.openCartDrawer()`, `window.closeCartDrawer()`). DEVEM ser registrados no contrato. Consumidores (quickbuy, header) DEVEM usar optional chaining. |
| **A6** | Se o drawer injetar HTML com ícones Lucide (ex: ícone de lixeira para excluir item), DEVE chamar `lucide.createIcons()` após a injeção. |
| **A8** | O fundo translúcido do drawer DEVE usar CSS custom properties (`var(--background-color)` com `color-mix` ou `rgba` dinâmico). NUNCA hardcodar hex/rgba temáticos. |
| **A9** | O drawer DEVE usar `data-state="open"|"closed"` para controlar visibilidade, com CSS correspondente em `app.css`. Segue o padrão existente de header, search, modal. |
| **A10** | Novo snipplet DEVE ser organizado por domain. Opções: criar `snipplets/cart/cart-drawer.tpl` (domain folder) ou manter como flat file `snipplets/cart-drawer.tpl`. Dado que `cart-panel.tpl` já é flat, manter consistência. |
| **A12** | O bundle carrega após Lucide e Swiper. O módulo pode assumir que `lucide` existe como global. |
| **A14** | Todos os ícones (fechar, lixeira, +, -) DEVEM usar `<i data-lucide="icon-name">`. |
| **D1** | JS lê dados do carrinho via `data-*` attributes no HTML renderizado pelo template. Operações AJAX de carrinho (add/remove/update) DEVEM ser delegadas ao legacy `store.js.tpl`. |
| **S2** | Novos globals para comunicação cross-module DEVEM seguir o padrão `window.fn = ...` (provider) e `window.fn?.()` (consumer). |
| **S3** | Estado do drawer: `data-state` (open/closed). Elementos internos: `hidden` attribute para show/hide simples. |
| **L5** | Zero jQuery. Vanilla JS apenas. |
| **R1** | Sem imports horizontais. O cart-drawer NÃO importa de item-card-quickbuy ou header. Comunicação via `window.*`. |
| **R3** | Novos `js-*` class selectors criarão contratos de binding entre o template e o módulo JS. DEVEM ser documentados. |
| **F4** | Cores do drawer DEVEM usar tokens do tema. |
| **F5** | Sem novos SVG snipplets. Usar Lucide. |
| **F6** | Sem side-effects na importação. Named export apenas. |
| **F9** | Sem imports entre módulos irmãos. |

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Justificativa:
- **Complexidade de integração com legacy**: As operações AJAX do carrinho (adicionar, remover, atualizar quantidade) são gerenciadas pelo `store.js.tpl` via jQuery. O módulo custom precisa interoperar sem duplicar funcionalidade AJAX, respeitando D1 e L5. Essa é a zona de maior risco.
- **Sincronização de estado**: Quando o quickbuy adiciona um item (via legacy AJAX), o drawer precisa refletir a mudança. Sem um sistema de eventos entre legacy e custom, isso requer ou MutationObserver ou um novo `window.*` callback definido em `store.js.tpl`.
- **Posicionamento abaixo do header**: Difere do padrão modal/drawer existente (fullscreen `position: fixed; top: 0`). Requer cálculo dinâmico da altura do header ou abordagem CSS diferente.
- **Dois comportamentos responsivos distintos**: Desktop (drawer lateral parcial abaixo do header) vs Mobile (fullscreen como filtros). Aumenta a superfície de CSS e lógica condicional.

## 7. Likely Impacted Areas (Scoped)

### Novos Arquivos
- `__src/js/modules/system/cart-drawer.js` — módulo principal
- `snipplets/cart-drawer.tpl` (ou `snipplets/cart/cart-drawer.tpl`) — template do drawer

### Arquivos Modificados
- `__src/js/index.js` — adicionar import e invocação de `cartDrawerSystem`
- `__src/css/app.css` — estilos para `.js-cart-drawer[data-state]`, animações, responsivo
- `snipplets/header/header-new.tpl` — trocar `<a href="{{ store.cart_url }}">` por trigger do drawer
- `layouts/layout.tpl` — incluir snipplet do cart drawer globalmente
- `__src/js/modules/system/item-card-quickbuy.js` — integrar com `window.openCartDrawer?.()` após adição ao carrinho (ou manter toast + atualizar drawer silenciosamente)

### Arquivos Potencialmente Impactados
- `static/js/store.js.tpl` — pode necessitar de um `window.*` callback para notificar o custom JS quando o carrinho é atualizado via AJAX
- `docs/architecture-map.md` — atualizar registros de A2, A3, A5/S2 (novos globals), R3 (novos `js-*` selectors)

## 8. Visual / Component Surface Impact

### Desktop
- **Header**: O link "Carrinho (N)" se torna um botão/trigger. Comportamento visual muda de navegação para toggle.
- **Drawer**: Novo componente visual — painel lateral direito, abaixo do header. Largura ~420px (consistente com modal drawer). Fundo translúcido com blur, alinhado ao design do header ativo.
- **Backdrop**: Transparente (sem escurecimento), cobre o restante da viewport para capturar clique fora.
- **Itens do carrinho**: Layout horizontal — imagem à esquerda, conteúdo à direita (título, variação, preço, controles de quantidade, botão excluir).

### Mobile
- **Drawer fullscreen**: Ocupa 100% da viewport, similar ao drawer de filtros da categoria.
- **Mesma estrutura interna** que desktop (itens, checkout button).
- **Animação**: Slide da direita para esquerda (consistente com padrões existentes).

### Componentes internos do drawer
- Lista scrollável de itens
- Item card: `[Foto] [Título + Variação + Preço + Qty Controls + Delete]`
- Controles de quantidade: botão -, input numérico editável, botão +
- Botão excluir: posição absoluta no canto superior direito do item
- Botão CTA: "Ir para Checkout" — fixed no bottom do drawer
- Total do carrinho visível acima do CTA

## 9. Architectural Constraints Summary

1. **Módulo em `system/`**: O carrinho é global, portanto DEVE residir em `__src/js/modules/system/`.
2. **Sem jQuery**: Toda manipulação DOM em vanilla JS. Operações AJAX delegadas ao legacy.
3. **`data-state` obrigatório**: O drawer DEVE usar `data-state="open"|"closed"` com CSS em `app.css`.
4. **Guard selector**: `.js-cart-drawer` (pré-registrado em A2).
5. **Named export**: `export const cartDrawerSystem = () => { ... }`.
6. **Cross-module via `window.*`**: Novos globals (ex: `window.openCartDrawer`, `window.closeCartDrawer`) DEVEM ser registrados em A5/S2.
7. **Sem imports horizontais**: Comunicação com quickbuy e header exclusivamente via `window.*`.
8. **Ícones Lucide**: Todos os ícones do drawer (fechar, lixeira, +, -) via `<i data-lucide="...">`.
9. **Cores via tokens**: Fundo translúcido via CSS custom properties, nunca hardcoded.
10. **Snipplet global**: O template do drawer DEVE ser incluído em `layout.tpl` para estar disponível em todas as páginas.
11. **Integração legacy**: As operações de carrinho (add/remove/update) são realizadas pelo `store.js.tpl`. O módulo custom gerencia apenas a UI do drawer. A sincronização de estado requer um mecanismo de callback entre legacy e custom (provavelmente um novo `window.*` global definido em `store.js.tpl` ou observação de mutações no DOM).
12. **Dois layouts responsivos**: Desktop (drawer parcial abaixo do header, ~420px) vs Mobile (fullscreen). DEVE ser resolvido via CSS media queries, não via JS condicional.
