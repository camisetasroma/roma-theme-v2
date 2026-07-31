# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
A2, A5, A9, S2, S3, R1, F9

### Invariant Tension Check
Nenhuma tensão identificada. A infraestrutura necessária já existe:
- `window.setHeaderMenuActive(boolean)` já está definido em `header.js` e documentado em A5/S2
- O `cart-drawer.js` já segue A2 (guard na linha 3: `if (!drawer) return;`)
- A comunicação será via `window.*` global com optional chaining, sem importação horizontal (R1/F9 preservados)
- Nenhum novo `data-state` é necessário (A9 preservado)

### Risk Level
**LOW**

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services
Nenhuma alteração necessária. Não há mudança em fluxo de dados, fetch, ou integração com plataforma.

### 2.2 State / Hooks

**Modificação: `__src/js/modules/system/cart-drawer.js`**

- Na função `openDrawer()`: adicionar chamada `window.setHeaderMenuActive?.(true)` ANTES do body lock (antes da linha 48 `document.body.style.overflow = "hidden"`), mas APÓS a captura do `preHeaderHeight` (após a linha 42). Isso garante que: (1) a altura do header é capturada no estado atual antes da transição, (2) o header transiciona para `active` enquanto o DOM ainda é visível e interativo.
- Na função `closeDrawer()`: adicionar chamada `window.setHeaderMenuActive?.(false)` APÓS a restauração do scroll (`window.scrollTo(0, scrollY)` na linha 77). Isso garante que o `header.js` recalcule o estado com base na posição real de scroll restaurada — se o scroll estiver acima de 50px na home, o header voltará a `transparent`; caso contrário, permanecerá `active`.
- Motivo: O cart-drawer precisa sinalizar ao header que um overlay está ativo, exatamente como o `menu.js` já faz. Sem essa sinalização, o header permanece `transparent` na home (scroll ≤ 50px) quando o carrinho está aberto.
- Constrangido por: A5, S2 (comunicação via `window.*` com optional chaining), R1/F9 (sem importação horizontal)

**Atualização de documentação: `docs/architecture-map.md`**

- Em A5: adicionar `cart-drawer.js` como consumidor de `window.setHeaderMenuActive(boolean)`
- Em S2: adicionar `cart-drawer.js` como consumidor de `window.setHeaderMenuActive(boolean)`
- Constrangido por: A5, S2 (todo consumidor de `window.*` global DEVE ser documentado no contrato)

### 2.3 UI / Components
Nenhuma alteração em templates. Os estados CSS `transparent`/`active` do header já estão implementados e estilizados em `app.css`. O `data-state` do header é controlado inteiramente pelo `header.js` via a flag `isMenuActive`.

### 2.4 Styling
Nenhuma alteração necessária. Os estilos para `data-state="transparent"` e `data-state="active"` já existem em `app.css:69-103`.

### 2.5 Assets
Nenhuma alteração necessária.

---

## 3. Execution Phases

### Phase 1: Sinalização no cart-drawer (funcionalidade core)
- Adicionar `window.setHeaderMenuActive?.(true)` em `openDrawer()` após captura de `preHeaderHeight` e antes do body lock
- Adicionar `window.setHeaderMenuActive?.(false)` em `closeDrawer()` após `window.scrollTo(0, scrollY)`
- Arquivo: `__src/js/modules/system/cart-drawer.js`
- Validação: Abrir carrinho na home (scroll = 0) → header deve transicionar para `active`. Fechar carrinho → header deve voltar a `transparent`. Abrir carrinho em outra página → sem mudança visual no header.

### Phase 2: Atualização do contrato arquitetural
- Atualizar A5 em `docs/architecture-map.md` para registrar `cart-drawer.js` como consumidor de `window.setHeaderMenuActive`
- Atualizar S2 em `docs/architecture-map.md` para registrar `cart-drawer.js` como consumidor de `window.setHeaderMenuActive`
- Validação: Verificar que o texto do contrato reflete a realidade do código

### Phase 3: Teste integrado
- Testar cenário 1: Home, scroll = 0, abrir carrinho → header fica `active`
- Testar cenário 2: Home, scroll = 0, abrir e fechar carrinho → header volta a `transparent`
- Testar cenário 3: Home, scroll > 50px, abrir e fechar carrinho → header permanece `active`
- Testar cenário 4: Outra página qualquer, abrir e fechar carrinho → header permanece `active` sem flicker
- Testar cenário 5: Abrir menu mobile, fechar menu, abrir carrinho → estados não conflitam

---

## 4. Risk Controls

### Edge Cases
- **Menu mobile + carrinho simultâneo:** No fluxo atual, o body lock do carrinho impede interação com o menu, então ambos não podem estar abertos simultaneamente. Se futuramente isso mudar, `isMenuActive` como boolean (em vez de contador) causará conflito — mas isso é fora de escopo desta correção.
- **Header height pós-transição:** O `preHeaderHeight` é capturado ANTES de `setHeaderMenuActive(true)`, garantindo que o offset do painel usa a altura do estado atual do header. Se a transição `transparent→active` alterar a altura, a diferença é negligível (mesmo height estrutural, apenas background/color mudam).
- **scrollY congelado durante body lock:** O header usa `window.scrollY` que fica congelado quando `body.style.position = "fixed"`. O `setHeaderMenuActive(true)` força `data-state="active"` independente de scroll, portanto não há conflito.
- **Escape key close:** O handler de `Escape` (linha 169) chama `closeDrawer()` que agora também chamará `setHeaderMenuActive(false)` — comportamento correto e consistente.

### Regression Zones
- **Header estado em outras páginas:** Em páginas com `data-initial-state="active"`, o `setHeaderMenuActive(false)` no close resultará em `isMenuActive = false` dentro do `header.js`, mas como o scroll listener no header verifica a posição de scroll E o `data-initial-state`, o header permanecerá `active`. Confirmar que o `headerAnimations` em `header.js` recalcula corretamente.
- **Menu mobile:** O `menu.js` também chama `setHeaderMenuActive`. Verificar que o fluxo menu→close→cart→open→close não deixa o header em estado inconsistente.
- **Cart drawer offset:** O cálculo de `panel.style.top` e `panel.style.height` em `openDrawer()` já captura `preHeaderHeight` antes de qualquer mudança. Validar que não há reflow inesperado.

### Strict Non-Modification Areas
- `__src/js/modules/system/header.js` — NÃO deve ser modificado. A lógica de `isMenuActive` e `setHeaderMenuActive` já suporta o caso.
- `__src/css/app.css` — NÃO deve ser modificado. Os estados CSS já existem.
- `snipplets/header/header-new.tpl` — NÃO deve ser modificado.
- `snipplets/cart/cart-drawer.tpl` — NÃO deve ser modificado.
- Qualquer outro módulo JS — NÃO deve ser modificado.
