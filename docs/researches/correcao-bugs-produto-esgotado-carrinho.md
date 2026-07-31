# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Quando um produto já adicionado ao carrinho fica esgotado (sem estoque), e o usuário tenta iniciar o checkout ou incrementar a quantidade desse item, o sistema remove o item silenciosamente, causando um bug visual no carrinho. O objetivo é: (1) corrigir o bug visual que ocorre ao remover o item esgotado, e (2) exibir feedback visual informando que o item foi removido por estar esgotado.

## 2. Assumptions (if any)

- A remoção do item esgotado é realizada pelo backend Nuvemshop (via `LS.*` APIs) — o tema não controla essa lógica de remoção, apenas a resposta visual.
- O "bug visual" refere-se a um problema no render do carrinho após a remoção automática do item pelo backend (provavelmente o `refreshCart()` em `cart-drawer.js` não trata corretamente o cenário de item removido pelo servidor por falta de estoque vs. item removido manualmente pelo usuário).
- O carrinho drawer (`cart-drawer.js`) é o componente principal afetado — não a página `/cart`.
- "Mostrar que o item esgotou" implica usar o sistema de toast existente (`window.showToast`) para notificar o usuário, não uma alteração na estrutura do carrinho em si.
- O cenário ocorre quando `refreshCart()` sincroniza o carrinho e detecta que um item foi removido pelo backend, diferente da remoção manual animada já existente.

## 3. Affected Architectural Domains

| Domínio | Impacto |
|---------|---------|
| `__src/js/modules/system/cart-drawer.js` | Principal — lógica de `refreshCart()`, `syncMeta()`, detecção de item removido pelo backend |
| `__src/js/modules/system/toast.js` | Consumido — `window.showToast()` para feedback de item esgotado |
| `snipplets/cart/cart-drawer.tpl` | Possível — estrutura HTML do drawer que é re-renderizada |
| `snipplets/cart-item-ajax.tpl` | Possível — template do item individual, pode precisar de data attributes para identificar itens |
| `static/js/store.js.tpl` | Referência — contém `LS.plusQuantity()`, `LS.changeQuantity()`, `LS.removeItem()` — lógica legada que dispara as operações de carrinho |

## 4. Applicable Invariants (Codes Only)

A1, A2, A5, A6, A9, S2, S3, D1, L5, L6, R3, F2, F4

## 5. Invariant Impact Explanation

- **A1** — Qualquer novo código JS deve estar em `__src/js/modules/system/cart-drawer.js` (módulo existente), não em `static/`.
- **A2** — O módulo `cart-drawer.js` já possui guard (`.js-cart-drawer`). Novas funções internas não precisam de guard adicional desde que estejam dentro do escopo do guard existente.
- **A5 / S2** — A comunicação com o toast DEVE usar `window.showToast?.({...})` (optional chaining). Nenhum novo `window.*` global é necessário se usar os existentes.
- **A6** — Se o feedback visual incluir ícones Lucide em HTML dinâmico, `lucide.createIcons()` deve ser chamado após inserção. O `refreshCart()` já faz isso.
- **A9 / S3** — Estado visual do drawer já usa padrão `data-state`. Qualquer novo estado de feedback deve usar `hidden` attribute (para show/hide simples) ou `data-state` (para transições CSS).
- **D1** — O JS deve detectar itens removidos pelo backend comparando o DOM antes/depois do `refreshCart()`, lendo `data-*` attributes. NÃO deve chamar APIs `LS.*` diretamente.
- **L5 / F2** — Zero jQuery no módulo. Toda manipulação DOM via vanilla JS.
- **L6** — Não chamar `LS.*` diretamente. A remoção de itens esgotados é responsabilidade do backend.
- **R3** — Seletores `js-*` são o contrato entre templates e JS. Novos seletores devem seguir o padrão existente.
- **F4** — Qualquer cor usada no feedback visual (toast, highlight de item removido) deve usar CSS custom properties, nunca hex/rgba hardcoded.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Justificativa:
- O bug afeta a experiência do usuário no fluxo de checkout (momento crítico de conversão).
- A correção envolve a interação entre o código custom (`cart-drawer.js`) e o backend Nuvemshop (`LS.*` APIs), que é uma fronteira delicada (D1, L6).
- É necessário entender exatamente como o backend comunica a remoção de itens esgotados (via resposta HTTP na atualização de quantidade, ou via o HTML re-renderizado no fetch de `refreshCart()`).
- O risco visual é que a solução pode introduzir inconsistências na animação de remoção se não sincronizar corretamente com o ciclo de `refreshCart()`.

## 7. Likely Impacted Areas (Scoped)

1. **`cart-drawer.js` → `refreshCart()`** — Precisa comparar itens antes/depois do fetch para detectar remoções pelo backend e disparar feedback.
2. **`cart-drawer.js` → `syncMeta()`** — Pode precisar de ajuste para tratar corretamente o cenário de carrinho que ficou vazio por remoção de esgotado.
3. **`cart-drawer.js` → lógica de quantidade** — O handler de `LS.plusQuantity()` / `LS.changeQuantity()` é no `store.js.tpl` (legado). O callback `window.onCartUpdate()` é o ponto onde o custom JS recebe o sinal de que algo mudou.
4. **Toast system** — Consumo existente via `window.showToast()`. Pode ser necessário um ícone ou estilo específico para "esgotado" vs. "adicionado".

## 8. Visual / Component Surface Impact

- **Cart Drawer** — O render visual após remoção de item esgotado precisa ser suave (sem "bugada"). Provavelmente a transição animada de remoção manual (opacity + slide) não é aplicada quando o backend remove o item — o `refreshCart()` simplesmente substitui o HTML inteiro.
- **Toast Notification** — Nova mensagem de toast informando que item X foi removido por estar esgotado. Usa o componente existente `window.showToast()`.
- **Header Badge** — O badge de quantidade do carrinho no header precisa ser atualizado corretamente após remoção (já é tratado por `syncMeta()`).
- **Empty State** — Se o item esgotado era o último, o estado vazio do carrinho deve ser exibido corretamente.

## 9. Architectural Constraints Summary

1. A detecção de itens esgotados deve ser feita no lado do cliente comparando estado do DOM antes/depois de `refreshCart()`, ou interpretando o HTML retornado pelo servidor — nunca chamando `LS.*` APIs diretamente.
2. O feedback ao usuário deve usar `window.showToast?.()` (sistema existente), não criar um novo mecanismo de notificação.
3. Toda a lógica deve residir em `cart-drawer.js` (módulo system existente). Não criar novos módulos.
4. Nenhuma cor hardcoded. Usar tokens do tema para qualquer estilização de feedback.
5. A solução não deve duplicar funcionalidade do `store.js.tpl` — deve complementar a camada legada, não substituí-la.
6. Se novos `data-*` attributes forem necessários nos templates de cart items para identificar produtos (e.g., `data-item-id`, `data-product-name`), eles devem ser adicionados nos `.tpl` correspondentes e documentados em R3.
7. O módulo `cart-drawer.js` já exporta `cartDrawerSystem` com guard em `.js-cart-drawer` — manter esse padrão (A2, A3).
