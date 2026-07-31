# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

Implementar duas barras de progresso visuais dentro do carrinho (cart drawer e possivelmente cart page):

1. **Barra de Descontos Progressivos**: Exibe progresso baseado na quantidade de itens no carrinho. Mensagem: "Faltam X itens para Y% Off". Requer configuração de thresholds (ex: a partir de N itens → X% de desconto).

2. **Barra de Frete Grátis**: Exibe progresso baseado no valor total do carrinho em relação a um valor mínimo para frete grátis. Mensagem: "Faltam R$X para você conseguir o frete grátis".

Ambas as barras ficam posicionadas abaixo da lista de produtos no carrinho, antes do footer/subtotal. Cada barra contém: (a) track de progresso com fill animado, (b) texto descritivo com valores dinâmicos.

**Configuração**: Necessário sistema de settings no admin para ativar/desativar e configurar valores de cada barra.

## 2. Assumptions (if any)

- **A-1**: A cor "Limão" referenciada no HTML de referência é um token de design (Figma). Não existe no `@theme` atual. Será necessário definir um token semântico ou usar uma cor existente do tema. Não se pode hardcodar um hex/rgba (F4).
- **A-2**: Os thresholds de desconto progressivo (ex: "5 itens = 10% OFF", "10 itens = 15% OFF") não vêm da plataforma Nuvemshop nativamente. Precisam ser configurados via `settings.txt` como campos de texto/número.
- **A-3**: A barra de frete grátis pode reutilizar dados da plataforma (`cart.free_shipping.min_price_free_shipping.min_price_raw` e `cart.subtotal`) que já são usados pelo sistema legado em `cart-panel.tpl` → `shipping-free-rest.tpl`. Porém, o cart drawer atual (`cart-drawer.tpl`) **não inclui** o snipplet de frete grátis.
- **A-4**: A fonte "Manrope" referenciada no HTML de referência é um artefato de design — o tema usa `--font-sans` / `--font-heading` do sistema de tokens. Não será usada diretamente.
- **A-5**: "Quantos itens tem no carrinho" refere-se a `cart.items_count` (total de unidades) ou à contagem de linhas distintas. Assumo `cart.items_count` (soma de quantidades) por ser mais relevante para descontos por volume.
- **A-6**: A atualização dinâmica das barras quando itens são adicionados/removidos via AJAX será tratada pelo `refreshCart()` do `cart-drawer.js`, que já faz fetch da página e substitui o HTML do drawer. As barras, sendo parte do template, serão automaticamente atualizadas nesse fluxo.
- **A-7**: O sistema legado de frete grátis (`LS.freeShippingProgress`) gerencia as classes `js-bar-progress`, `js-ship-free-rest` etc. no cart-panel (popup legado). Para o cart drawer, uma implementação independente será necessária, possivelmente via JS custom ou via dados `data-*` renderizados pelo template.

## 3. Affected Architectural Domains

| Domain | Scope |
|--------|-------|
| **Template Layer** | `snipplets/cart/cart-drawer.tpl` — inserção das barras de progresso. Possivelmente novo snipplet em `snipplets/cart/` para as barras. |
| **Template Layer** | `templates/cart.tpl` — se as barras devem aparecer também na página de carrinho full. |
| **Configuration Layer** | `config/settings.txt` — novos settings para ativar/configurar thresholds de desconto e valor de frete grátis. |
| **Configuration Layer** | `config/translations.txt` — novas strings de tradução para mensagens das barras. |
| **Source Layer (CSS)** | `__src/css/app.css` — possível novo token de cor para o fill da barra (se não coberto por tokens existentes). Estilos de animação da barra de progresso. |
| **Source Layer (JS)** | `__src/js/modules/system/cart-drawer.js` — se a barra de descontos progressivos precisar de cálculo client-side (os thresholds vêm de settings mas a contagem de itens muda via AJAX). |
| **Build Layer** | Rebuild necessário após alterações em JS/CSS. |

## 4. Applicable Invariants (Codes Only)

A1, A2, A3, A5, A6, A8, A9, A10, A13, A14, D1, F4, F5, F6, L5, L6, R3, S2, S3, T1, T2

## 5. Invariant Impact Explanation

| Invariant | Impact |
|-----------|--------|
| **A1** | Se JS custom for necessário para calcular progresso das barras, deve ficar em `__src/js/modules/system/` (provavelmente dentro do próprio `cart-drawer.js` ou novo módulo). |
| **A2** | Qualquer novo módulo JS deve ter guard de DOM element. Se incorporado no `cart-drawer.js`, o guard existente (`.js-cart-drawer`) já cobre. |
| **A3** | Se novo módulo, deve ser named export + invocado em `index.js`. Se extensão do `cart-drawer.js`, não precisa de novo export. |
| **A5/S2** | Se o cart drawer precisar comunicar estado das barras para outros módulos (improvável), deve usar `window.*`. Mais provável: o `window.onCartUpdate()` existente já dispara `refreshCart()` que atualizará as barras via re-render do HTML. |
| **A6** | Se as barras usarem ícones Lucide, `lucide.createIcons()` deve ser chamado após innerHTML. O `syncMeta` do cart-drawer.js já faz isso. |
| **A8/F4/T2** | A cor "Limão" do design NÃO pode ser hardcoded. Deve usar um token semântico do `@theme` (ex: `--color-fg` para verde) ou criar um novo token derivado de CSS custom properties da plataforma. Se for uma cor fixa de destaque, deve ser definida via `settings.txt` (color picker) → `style-colors.scss.tpl` → `@theme`. |
| **A10** | Novo snipplet de barras DEVE ir em `snipplets/cart/`, NUNCA na raiz de `snipplets/`. |
| **A13** | Novos settings devem seguir o formato existente: snake_case, agrupados sob a categoria "Carrito de compras" com title/description. |
| **A14** | Ícones nas barras devem usar Lucide. |
| **D1** | JS lê dados do DOM via `data-*` attributes. Os valores de progresso (total do carrinho, contagem de itens) devem ser renderizados como `data-*` attributes no template para que o JS possa calcular percentuais. |
| **L5** | Zero jQuery no JS custom. |
| **L6** | Não deve chamar `LS.*` para ler dados do carrinho. Deve usar dados renderizados no template. |
| **R3** | Novos seletores `js-*` introduzidos para as barras devem ser documentados no contrato. |
| **S3** | Animações de transição da barra (fill) devem usar CSS transitions, preferencialmente via classes Tailwind ou `data-*` attributes, não `element.style.*` para valores estáticos. `element.style.width` é aceitável para o width percentual da barra (valor computado em runtime). |
| **T1** | Valores de threshold de desconto e valor mínimo de frete grátis devem ser configuráveis via settings, não hardcoded. |

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

**MEDIUM**

Justificativa:
- A barra de frete grátis tem precedente no sistema legado (`shipping-free-rest.tpl`, `LS.freeShippingProgress`), reduzindo risco de design. Porém, adaptar para o cart drawer custom requer cuidado para não duplicar lógica do legado nem conflitar com `LS.freeShippingProgress`.
- A barra de descontos progressivos é completamente nova — não existe mecanismo nativo na plataforma Nuvemshop para isso. Os thresholds terão que ser configurados manualmente via settings e a lógica será puramente client-side, sem validação backend (o desconto real teria que ser configurado separadamente na plataforma como promoção).
- A cor "Limão" do design precisa ser mapeada para o sistema de tokens sem hardcodar, o que requer decisão de design sobre qual token usar ou se criar um novo.
- O `refreshCart()` via fetch+replace já é o mecanismo de atualização — as barras no template serão naturalmente atualizadas. Risco baixo de dessincronia.

## 7. Likely Impacted Areas (Scoped)

| File | Change Type |
|------|-------------|
| `snipplets/cart/cart-drawer.tpl` | Inserção de markup das barras entre `.js-ajax-cart-list` e `.js-cart-drawer-footer` |
| `config/settings.txt` | Novos campos na categoria "Carrito de compras": toggles de ativação, valores de threshold de desconto (itens + percentual), valor mínimo de frete grátis |
| `config/translations.txt` | Strings para "Faltam X itens para Y% Off", "Faltam R$X para frete grátis", "Frete grátis conquistado", etc. |
| `__src/css/app.css` | Estilos para barra de progresso (track, fill, animação de transição). Possível novo token de cor no `@theme` |
| `__src/js/modules/system/cart-drawer.js` | Possível lógica para calcular porcentagem de progresso das barras e atualizar width do fill via `element.style.width`. Ou, se o cálculo for feito no template (via Twig math), pode não precisar de JS adicional |
| `templates/cart.tpl` | Se as barras devem aparecer na página de carrinho full (fora de escopo? não especificado) |

## 8. Visual / Component Surface Impact

- **Novas classes `js-*`** a serem criadas: seletores para as barras de progresso (ex: `.js-cart-progress-discount`, `.js-cart-progress-shipping`, `.js-cart-progress-fill`, `.js-cart-progress-text`)
- **Novo markup**: Duas seções de barra de progresso, cada uma com: container → track (fundo) → fill (preenchimento animado) + texto descritivo
- **Impacto no layout do cart drawer**: As barras adicionam altura ao drawer entre a lista de itens e o footer. Em telas pequenas, isso comprime o espaço de scroll da lista de itens
- **Cor de destaque**: O design referencia "Limão" (verde-lima). Se for cor de destaque para a barra, precisa ser resolvida via sistema de tokens. Opções: (a) usar `--color-fg` existente, (b) criar novo color picker em settings para "cor de destaque de promoções", (c) usar a `--primary-color` da plataforma
- **Fonte**: O design referencia "Manrope" — será substituída por `font-sans` do tema (variável)
- **Animação**: O fill da barra precisa de `transition` em `width` para animar o progresso suavemente

## 9. Architectural Constraints Summary

1. **Cor não pode ser hardcoded** — A cor "Limão" do design deve ser mapeada para um token do sistema de cores ou criada como nova variável configurável. Hardcodar `#hex` ou `rgba(r,g,b,a)` com cor tema-dependente viola F4/A8/T2.

2. **Snipplet deve ir em `snipplets/cart/`** — Nunca na raiz de `snipplets/` (A10).

3. **Thresholds via settings, não hardcoded** — Os valores de configuração (quantidade de itens para desconto, percentual de desconto, valor mínimo de frete grátis) devem ser definidos em `config/settings.txt` e consumidos via `{{ settings.* }}` nos templates (T1/A13).

4. **Sem jQuery no JS custom** — Qualquer lógica JS para as barras deve usar vanilla JS em `__src/js/modules/system/` (L5/F2).

5. **Dados via template, não via API** — O JS deve ler dados de progresso (total, contagem) a partir de `data-*` attributes renderizados pelo template, não chamando `LS.*` APIs (D1/L6). Exceção: `cart.subtotal`, `cart.items_count`, `cart.free_shipping.*` são template variables renderizadas diretamente.

6. **Atualização via refreshCart()** — O mecanismo existente de fetch+replace do cart-drawer.js já atualiza o HTML inteiro do drawer. As barras, sendo parte do template, serão atualizadas automaticamente. Não criar canal de atualização paralelo.

7. **Frete grátis: cuidado com duplicação** — Existe sistema legado (`LS.freeShippingProgress`, `shipping-free-rest.tpl`) que gerencia barra de frete grátis no cart-panel (popup legado). O cart drawer tem seu próprio sistema de refresh. A implementação para o drawer deve ser independente e não conflitar com o legado.

8. **Descontos progressivos: gap plataforma vs. UI** — A barra de descontos é puramente visual/motivacional. O desconto real precisa ser configurado separadamente na plataforma Nuvemshop como promoção. A barra não aplica desconto — apenas exibe progresso. Essa distinção deve ser clara na implementação.

9. **Se novo módulo JS for criado** — Deve ter named export, DOM guard, invocação em `index.js`, e a contagem de exports em A3 deve ser atualizada (A1/A2/A3/F6).

10. **Lucide para ícones** — Se as barras incluírem ícones, devem usar `<i data-lucide="...">` e chamar `lucide.createIcons()` após inserção dinâmica (A6/A14).
