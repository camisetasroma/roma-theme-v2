---
feature: pagina-de-produto
spec: 06-calculadora-de-frete
status: done
depends_on: ["01-fundacao-layout-e-preco"]
---

## Objetivo

Reestilizar em Tailwind a calculadora de frete exibida na PDP (input de CEP
+ botão "Consultar Frete"), sem tocar no arquivo compartilhado com o
carrinho e preservando 100% do contrato de classes/IDs que
`static/js/store.js.tpl` já usa para calcular e exibir o resultado do
frete.

**Nota de posição**: confirmado no Figma node `131:1503` ("Desktop - 3")
que, tanto no mobile quanto no desktop, este bloco fica **depois** do
carrossel "Leve junto" (spec 09) e **antes** dos accordions (spec 08),
dentro do mesmo fluxo vertical — no desktop, dentro da coluna direita de
564px da spec 01, sem mudança de estrutura interna do componente.

## Escopo

- Novo: `snipplets/product/product-shipping-calculator.tpl` — versão
  específica da PDP, criada do zero copiando a estrutura funcional de
  `snipplets/shipping/shipping-calculator.tpl` mas SEM os ramos
  condicionais `{% if product_detail %}` (aqui é sempre contexto de
  produto) e com marcação Tailwind em vez de Bootstrap.
- `snipplets/product/product-form.tpl` — só a linha que hoje faz
  `{% include "snipplets/shipping/shipping-calculator.tpl" with
  {'shipping_calculator_variant': ..., 'product_detail': true} %}` passa a
  incluir o novo arquivo.
- **PROIBIDO** editar `snipplets/shipping/shipping-calculator.tpl` e
  `snipplets/cart-totals.tpl` nesta spec — esse arquivo continua servindo
  exclusivamente o carrinho (`product_detail: false`), que não faz parte
  desta feature. Qualquer necessidade percebida de tocar neles exige parar
  e perguntar ao usuário.
- Também não editar `snipplets/shipping/branches.tpl` (o link de lojas
  físicas incluído ao lado, fora do escopo desta spec).

## Atenção — comportamento legado não totalmente claro

Ao investigar `static/js/store.js.tpl`, o clique em `.js-calculate-shipping`
(linha ~2162) só chama `LS.calculateShippingAjax(...)` quando
`jQueryNuvem(".js-cart-item").length` é verdadeiro (ou seja, quando há itens
de carrinho na página) — os call sites encontrados de
`LS.calculateShippingAjax` (linhas ~2173 e ~2251) hardcodam
`#cart-shipping-container`, não `#product-shipping-container`. Não ficou
claro nesta investigação onde exatamente o cálculo é disparado no contexto
da PDP (pode ser via um componente de plataforma separado, ou via outro
trecho do arquivo não localizado). **Por isso**:

- [ ] Antes de qualquer mudança, testar no preview atual (sem alterações)
      o botão "Consultar Frete" na PDP de um produto real e documentar o
      comportamento observado (calcula e mostra opções? não faz nada?
      redireciona?).
- [ ] Depois da reestilização, repetir o mesmo teste e confirmar
      comportamento idêntico ao baseline. Se o comportamento já era
      quebrado/incompleto antes da mudança, isso é um bug pré-existente
      fora do escopo desta spec — não tentar consertar a lógica de
      `store.js.tpl` aqui (F1/A4), só reportar no relatório de conformidade.

## Critérios de aceite

- [ ] Visual conforme Figma: input de CEP + botão "Consultar Frete" lado a
      lado, no padrão de `TextInput`/botão neutro já usado em outras partes
      da PDP (mesmo token `[background:rgba(0,0,0,0.05)]`).
- [ ] Preserva exatamente (podem mudar só as classes de estilo, nunca os
      nomes/IDs abaixo): `id="product-shipping-container"` no wrapper (já
      existe em `product-form.tpl`, fora desta spec — não duplicar),
      `.js-shipping-calculator-container` (no ancestral, também fora desta
      spec), `.js-shipping-calculator-head`, `.js-shipping-calculator-form`,
      `.js-shipping-calculator-with-zipcode`,
      `.js-shipping-calculator-current-zip`,
      `.js-shipping-calculator-change-zipcode`, `.js-shipping-input`,
      `.js-calculate-shipping`, `.js-calculate-shipping-wording`,
      `.js-calculating-shipping-wording`, `.js-shipping-calculator-spinner`,
      `.js-shipping-calculator-response`, `.js-ship-calculator-error`,
      `.js-ship-calculator-common-error`, `.js-ship-calculator-external-error`,
      `data-store="shipping-calculator"`, `data-shipping-url` (se aplicável
      no wrapper pai), `input[name="zipcode"]`, `input[name="variant_id"]`
      quando `shipping_calculator_variant` existir.
- [ ] Modal de país de entrega (`languages | length > 1`) preservado,
      reaproveitando `snipplets/modal.tpl` como hoje (com
      `country_modal_id = 'product-shipping-country'`, fixo — não precisa
      mais do ternário `product_detail`).
- [ ] Nenhuma mudança visual ou funcional em `snipplets/cart-totals.tpl`/na
      página de carrinho — validar visualmente essa página também.
- [ ] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A8/F4 — sem cor hardcoded.
- A10 — novo snipplet dentro de `snipplets/product/` (domínio já existe).
- F1/A4 — `static/js/store.js.tpl` não é editado.

## Referências de padrão

- `snipplets/shipping/shipping-calculator.tpl` (arquivo original,
  compartilhado — usar como referência funcional, não editar).
- `snipplets/grid/item-card.tpl` / pills de `product-variants.tpl` (spec 04)
  — padrão visual de input/botão neutro em Tailwind.
