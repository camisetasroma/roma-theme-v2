# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A1, A2, A5, A6, A9, S2, S3, D1, L5, L6, R3, F2, F4

### Invariant Tension Check
Nenhuma tensão detectada. A solução opera inteiramente dentro dos limites do módulo existente `cart-drawer.js` (A1), usa o sistema de toast existente via `window.showToast?.()` (A5/S2), e detecta remoções comparando estado do DOM antes/depois de `refreshCart()` sem chamar `LS.*` diretamente (D1/L6).

### Risk Level
**MEDIUM** — A correção afeta o fluxo de checkout (conversão). Envolve a fronteira entre código custom e backend Nuvemshop. Requer sincronização cuidadosa entre detecção de itens removidos pelo backend e feedback visual.

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
**Nenhuma alteração necessária.** Não há camada de dados custom — os dados vêm do DOM renderizado pelo backend Nuvemshop via `fetchPage()` já existente.

### 2.2 State / Hooks

**Modificar: `__src/js/modules/system/cart-drawer.js` → `refreshCart()`**

- **O que**: Antes de substituir o `innerHTML` da lista de itens, capturar os `data-item-id` de todos os `.js-cart-item` locais. Após receber o HTML remoto, comparar com os `data-item-id` remotos. A diferença representa itens removidos pelo backend (esgotados).
- **Por que**: Atualmente `refreshCart()` substitui o HTML cegamente — não detecta se o backend removeu itens por falta de estoque. O resultado é um "pulo" visual sem feedback ao usuário.
- **Invariantes**: D1 (leitura de dados via `data-*` attrs do DOM), S3 (estado via manipulação DOM vanilla).

**Modificar: `__src/js/modules/system/cart-drawer.js` → nova função interna `detectRemovedItems(localList, remoteList)`**

- **O que**: Função interna (closure, não exportada) que compara arrays de `data-item-id` e retorna info dos itens que desapareceram (id + nome do produto extraído do DOM local antes da substituição).
- **Por que**: Encapsular a lógica de detecção para manter `refreshCart()` legível.
- **Invariantes**: A1 (código dentro do módulo existente), L5 (vanilla JS).

**Modificar: `__src/js/modules/system/cart-drawer.js` → `refreshCart()` pós-detecção**

- **O que**: Após detectar itens removidos pelo backend, chamar `window.showToast?.()` para cada item removido (ou um toast consolidado se múltiplos). A mensagem deve informar o nome do produto e que foi removido por estar esgotado.
- **Por que**: O usuário precisa saber por que o item sumiu do carrinho.
- **Invariantes**: A5/S2 (comunicação via `window.showToast?.()` com optional chaining), F4 (sem cores hardcoded — o toast system já usa tokens do tema).

**Modificar: `__src/js/modules/system/cart-drawer.js` → `refreshCart()` animação de remoção**

- **O que**: Quando itens removidos pelo backend são detectados, em vez de substituir o `innerHTML` imediatamente, primeiro animar a saída dos itens removidos (mesma animação de fade+slide+collapse já usada na remoção manual: opacity→0, translateX→40px, maxHeight→0) e DEPOIS substituir o HTML com o conteúdo remoto.
- **Por que**: Isso elimina o "bug visual" — o pulo abrupto causado pela substituição direta do HTML quando o backend remove um item. A animação dá continuidade visual.
- **Invariantes**: S3 (element.style para valores computados em runtime — maxHeight, opacity, transform).

### 2.3 UI / Components

**Modificar: `snipplets/cart/cart-drawer.tpl` → `.js-cart-item`**

- **O que**: Adicionar `data-item-name="{{ item.short_name }}"` ao elemento `.js-cart-item` (ao lado do `data-item-id` existente).
- **Por que**: O JS precisa capturar o nome do produto ANTES de substituir o HTML para incluir no toast de feedback. Atualmente o nome está em um `<a>` interno sem atributo de fácil acesso — adicionar um `data-*` no container é mais robusto e segue o padrão existente de `data-item-id`.
- **Invariantes**: R3 (novos `data-*` attrs devem ser documentados no contrato), D1 (JS lê dados via `data-*` attrs).

### 2.4 Styling
**Nenhuma alteração necessária.** A animação de remoção usa `element.style.*` inline (padrão já estabelecido nas linhas 210-227 do `cart-drawer.js`). O toast system já possui sua própria estilização via `data-state` e `app.css`.

### 2.5 Assets
**Nenhuma alteração necessária.** Nenhum ícone ou asset novo é requerido. O toast system já suporta ícones via o parâmetro `icon` do `showToast()`.

---

## 3. Execution Phases

### Phase 1: Template — Adicionar data attribute de nome do produto
1. Modificar `snipplets/cart/cart-drawer.tpl` para adicionar `data-item-name="{{ item.short_name }}"` ao `.js-cart-item`.
- **Testável**: Inspecionar o DOM do carrinho e confirmar que cada item tem o atributo `data-item-name` com o nome correto.

### Phase 2: JS — Detecção de itens removidos pelo backend
1. Criar função interna `detectRemovedItems(localList, remoteDoc)` em `cart-drawer.js` que:
   - Coleta `data-item-id` + `data-item-name` de cada `.js-cart-item` na lista local.
   - Coleta `data-item-id` de cada `.js-cart-item` na lista remota (do doc fetchado).
   - Retorna array de `{ id, name }` dos itens que existem localmente mas não remotamente.
2. Modificar `refreshCart()` para chamar `detectRemovedItems()` ANTES de substituir o innerHTML.
- **Testável**: Adicionar um `console.log` temporário com os itens detectados. Simular esgotamento no admin, tentar incrementar quantidade, verificar que a detecção identifica corretamente os itens removidos.

### Phase 3: JS — Animação de saída e feedback via toast
1. Modificar `refreshCart()` para, quando itens removidos são detectados:
   - Animar os elementos `.js-cart-item` correspondentes (fade+slide+collapse — reutilizando o padrão visual das linhas 210-227).
   - Após a animação concluir (~450ms), substituir o innerHTML com o conteúdo remoto e chamar `syncMeta(doc)`.
   - Chamar `window.showToast?.()` com mensagem informando o(s) produto(s) removido(s) por indisponibilidade.
2. Quando NENHUM item foi removido pelo backend, manter o comportamento atual (substituição direta do innerHTML + syncMeta).
- **Testável**: Adicionar produto ao carrinho → esgotar o produto no admin → abrir o drawer ou tentar incrementar quantidade → confirmar que: (a) o item anima a saída suavemente, (b) um toast aparece informando o nome do produto esgotado, (c) o carrinho re-renderiza corretamente após a animação, (d) badges e footer atualizam, (e) se era o último item, o empty state aparece.

---

## 4. Risk Controls

### Edge Cases
- **Múltiplos itens esgotados simultaneamente**: A detecção deve iterar todos os itens removidos. O toast pode consolidar ("X produtos foram removidos por indisponibilidade") ou mostrar um toast por item (avaliar UX — um toast consolidado é mais limpo).
- **Todos os itens esgotados (carrinho fica vazio)**: A animação deve concluir antes de exibir o empty state. O `syncMeta()` já trata o display do empty state e ocultação do footer — deve rodar APÓS a animação.
- **Nenhum item removido (cenário normal)**: O fluxo deve ser idêntico ao atual — substituição direta sem animação extra. A detecção retorna array vazio → caminho rápido.
- **refreshCart() chamado durante animação em andamento**: Garantir que a animação não é interrompida por um segundo `refreshCart()`. Considerar uma flag `isAnimating` que faz o segundo `refreshCart()` esperar ou ser ignorado.
- **Item removido manualmente pelo usuário + item removido pelo backend na mesma operação**: A remoção manual já remove o elemento do DOM (linha 231). Quando `refreshCart()` roda depois (via `scheduleRemoveSync`), o item removido manualmente não estará no DOM local, então `detectRemovedItems` não o encontrará — sem conflito.
- **fetchPage() falha (rede)**: O `.catch(() => {})` atual silencia o erro. A detecção não roda — sem regressão.

### Regression Zones
- **Remoção manual de itens**: A animação existente (linhas 188-243) NÃO deve ser afetada. O novo código opera apenas dentro de `refreshCart()`, que é separado do handler de click em `.js-cart-remove-btn`.
- **Abertura do drawer**: `openDrawer()` chama `refreshCart()`. Se nenhum item foi removido pelo backend, o comportamento deve ser idêntico ao atual (sem delay extra de animação).
- **`window.onCartUpdate()`**: Chamado pelo `store.js.tpl` após `LS.addToCartEnhanced`. Deve continuar funcionando normalmente — a detecção de remoção neste caso tipicamente retornará vazio (adição de item, não remoção).
- **Badge sync**: `syncMeta()` e o `MutationObserver` devem continuar sincronizando corretamente após a animação.

### Strict Non-Modification Areas
- `static/js/store.js.tpl` — Referência apenas. Lógica do `LS.*` NÃO deve ser alterada.
- `__src/js/modules/system/toast.js` — Consumir via `window.showToast?.()`, não modificar.
- `__src/js/modules/system/modal.js` — Não relacionado.
- `__src/js/index.js` — Nenhuma nova importação necessária (o módulo `cart-drawer.js` já é importado).
- `__src/css/app.css` — Nenhuma alteração de estilo necessária.
- `snipplets/cart-item-ajax.tpl` — Template da página `/cart` (não do drawer). Não modificar.
- Nenhum arquivo em `static/` deve ser editado diretamente (A4).
