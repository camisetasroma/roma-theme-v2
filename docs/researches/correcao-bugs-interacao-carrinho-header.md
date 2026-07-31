# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Corrigir a interação entre o cart-drawer e o header para que:

- **Home (scroll no topo):** Ao abrir o carrinho com scroll em posição 0, o header DEVE transicionar de `data-state="transparent"` para `data-state="active"`. Ao fechar o carrinho, o header DEVE retornar a `data-state="transparent"`.
- **Home (scroll abaixo de 50px):** O header já está `active` pelo scroll. Ao abrir o carrinho, o header DEVE permanecer `active`. Ao fechar, o estado do header DEVE ser recalculado com base na posição de scroll atual.
- **Outras páginas:** O `data-initial-state` é `"active"`, portanto o header já está ativo em qualquer posição de scroll. O carrinho DEVE abrir e fechar sem alterar o estado do header.

**Problema raiz identificado:** O `cart-drawer.js` NÃO sinaliza ao `header.js` que o carrinho foi aberto/fechado. Não existe chamada a `window.setHeaderMenuActive()` dentro do cart-drawer. Quando o carrinho abre na home com scroll no topo, o header permanece em `transparent`, criando inconsistência visual (carrinho aberto sobre header transparente).

## 2. Assumptions (if any)

- O comportamento desejado de "ativar o header" ao abrir o carrinho é equivalente ao que o `menu.js` já faz ao abrir o menu mobile/desktop: chamar `window.setHeaderMenuActive(true)`.
- O header em outras páginas (`data-initial-state="active"`) já funciona corretamente porque o estado "active" é o fallback — o bug é visível APENAS na home quando `scrollY <= 50` e `isMenuActive === false`.
- O `body lock` (position: fixed) aplicado pelo cart-drawer ao abrir NÃO interfere no cálculo de `scrollY` do header, pois o header usa `window.scrollY` que é congelado durante o body lock.
- O cart-drawer panel já calcula offset baseado na altura do header (lines 11-22 e 38-61 do cart-drawer.js), portanto a altura do header em ambos os estados (transparent/active) precisa ser considerada. Se o header mudar de tamanho ao transicionar para active, o offset pode precisar ser recalculado.

## 3. Affected Architectural Domains

| Domínio | Impacto |
|---------|---------|
| `__src/js/modules/system/cart-drawer.js` | Precisa sinalizar ao header via `window.setHeaderMenuActive()` no open/close |
| `__src/js/modules/system/header.js` | Receptor — lógica existente de `isMenuActive` já suporta o caso. Nenhuma alteração necessária no header |
| `__src/css/app.css` | Nenhuma alteração necessária — os estados CSS `transparent`/`active` já existem |
| `snipplets/header/header-new.tpl` | Nenhuma alteração necessária |
| `snipplets/cart/cart-drawer.tpl` | Nenhuma alteração necessária |

## 4. Applicable Invariants (Codes Only)

A2, A5, A9, S2, S3, R1, F9

## 5. Invariant Impact Explanation

- **A2**: O cart-drawer já possui guard (`if (!drawer) return;`). Nenhum impacto.
- **A5 / S2**: A comunicação cart→header DEVE usar `window.setHeaderMenuActive?.(true/false)` (optional chaining). Este global já está registrado no contrato (definido em `header.js`, consumido por `menu.js`). O cart-drawer se torna um SEGUNDO consumidor deste global. O contrato A5/S2 DEVE ser atualizado para registrar `cart-drawer.js` como consumidor adicional.
- **A9**: O header usa `data-state="transparent"|"active"`. O cart-drawer usa `data-state="open"|"closed"`. Ambos os padrões já estão conformes com A9. Nenhum novo `data-state` precisa ser criado.
- **S2**: A chamada `window.setHeaderMenuActive?.(true)` no `openDrawer()` e `window.setHeaderMenuActive?.(false)` no `closeDrawer()` é o padrão correto. Consumo via optional chaining conforme contrato.
- **S3**: Nenhum novo mecanismo de estado é introduzido. A interação usa o mecanismo existente (`data-state` via `window.*` global).
- **R1 / F9**: O cart-drawer NÃO importará do header. A comunicação é 100% via `window.*` global. Sem violação.

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**LOW**

Justificativa: A infraestrutura para esta correção já existe. O `window.setHeaderMenuActive()` é um global documentado e testado pelo `menu.js`. A mudança no cart-drawer é cirúrgica — duas linhas de chamada (open + close). Não há alteração em CSS, templates ou no header.js.

**Risco secundário (LOW):** Se o menu mobile E o carrinho estiverem abertos simultaneamente e o usuário fechar o carrinho, `setHeaderMenuActive(false)` desativará o header mesmo com o menu ainda aberto. Contudo, o menu mobile e o carrinho não são abertos simultaneamente no fluxo atual (o body lock do carrinho impede interação com o menu). Se futuramente isso mudar, o `isMenuActive` precisaria de um contador em vez de boolean.

## 7. Likely Impacted Areas (Scoped)

| Arquivo | Tipo de mudança |
|---------|----------------|
| `__src/js/modules/system/cart-drawer.js` | Adicionar chamadas `window.setHeaderMenuActive?.()` em `openDrawer()` e `closeDrawer()` |
| `docs/architecture-map.md` | Atualizar registro de consumidores de `window.setHeaderMenuActive` (A5/S2) para incluir `cart-drawer.js` |

## 8. Visual / Component Surface Impact

- **Home (scroll no topo):** O header passará de transparente para ativo (com background blur e cores de contraste) ao abrir o carrinho. Isso é o comportamento correto e esperado.
- **Home (scroll abaixo de 50px):** Sem mudança visual — header já está ativo.
- **Outras páginas:** Sem mudança visual — header já está ativo (initial-state = active).
- **Cart-drawer panel offset:** O offset calculado em `applyDesktopOffset()` usa `header.offsetHeight`. Se a transição transparent→active mudar a altura do header, o offset pré-calculado em `openDrawer()` (lines 38-42) captura a altura ANTES da transição. Isso pode causar 1-2px de diferença. O impacto visual é negligível pois ambos os estados do header têm a mesma altura estrutural (apenas background/color mudam, não height).

## 9. Architectural Constraints Summary

1. A comunicação DEVE ser via `window.setHeaderMenuActive?.()` — NUNCA importar header.js diretamente (R1, F9, A5)
2. O consumo DEVE usar optional chaining `?.()` (S2)
3. Nenhum novo `window.*` global é necessário — reutilizar o existente
4. O contrato arquitetural (A5, S2) DEVE ser atualizado para documentar `cart-drawer.js` como consumidor
5. As chamadas DEVEM ser posicionadas ANTES do body lock em `openDrawer()` (para que o header transicione enquanto ainda visível) e APÓS a restauração do scroll em `closeDrawer()` (para que o header recalcule com a posição real de scroll)
6. O cart-drawer já registra 3 `window.*` globals (`openCartDrawer`, `closeCartDrawer`, `onCartUpdate`) que NÃO estão documentados no contrato A5/S2 — isso é uma inconsistência pré-existente que DEVE ser corrigida separadamente
