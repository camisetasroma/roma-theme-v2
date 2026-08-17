---
feature: pagina-de-produto
spec: 05-quantidade
status: done
depends_on: ["01-fundacao-layout-e-preco"]
---

## Objetivo

Reestilizar o stepper de quantidade da PDP (`snipplets/product/
product-quantity.tpl`) em Tailwind no padrão visual do Figma
(`quantityContainer`: label "Quantidade:" + botões `-`/`+` e input central),
preservando o comportamento legado (sem JS novo).

## Escopo

- `snipplets/product/product-quantity.tpl` — arquivo inteiro.
- Proibido nesta spec: qualquer JS novo, `snipplets/forms/form-input.tpl`
  (o embed continua sendo usado — só as classes passadas mudam), variantes,
  frete, CTA.

**Nota de integração com a spec 04**: no Figma node `131:1503` ("Desktop -
3"), a partir de `lg:` este componente fica **ao lado** do bloco de
tamanho (não abaixo, como no mobile). O componente em si (label +
`-`/input/`+`) não muda de estrutura interna entre breakpoints — só a
posição dele no layout pai muda, o que é responsabilidade do wrapper
definido na spec 04. Não é necessário fazer nada diferente aqui além de
garantir que o componente não dependa de estar em largura cheia para
funcionar visualmente (ex.: evitar `w-full` forçado onde o Figma mostra
largura de conteúdo).

## Critérios de aceite

- [ ] Visual conforme Figma: label "Quantidade:" acima, botões quadrados
      `-`/`+` com fundo `[background:rgba(0,0,0,0.05)]` (mesmo token neutro
      usado em `item-card-quickbuy`/`item-card.tpl`) e input numérico
      central.
- [ ] Preserva exatamente as classes/atributos lidos por `store.js.tpl`:
      `.js-quantity` (container), `.js-quantity-up`, `.js-quantity-down`,
      `.js-quantity-input`, `data-component="adding-amount.value"`, `min="1"`.
- [ ] Incrementar/decrementar continua funcionando via o binding jQuery
      legado, sem reload e sem necessidade de JS novo.
- [ ] Mensagem de "último produto" (`settings.last_product`) preservada tal
      como está hoje (classe `.js-last-product`, texto de
      `settings.last_product_text`).
- [ ] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A8/F4 — sem cor hardcoded (usar `rgba(0,0,0,0.05)` conforme permitido).
- F1/A4 — `static/js/store.js.tpl` não é editado.
- T1 — texto de "último produto" continua vindo de `settings.last_product_text`.

## Referências de padrão

- `snipplets/grid/item-card.tpl` — botão quadrado com fundo
  `[background:rgba(0,0,0,0.05)]` e ícone Lucide centralizado.
- `__src/js/modules/system/item-card-quickbuy.js` — não é usado aqui (essa
  spec não introduz JS novo), mas mostra o mesmo padrão visual de botão
  circular/quadrado neutro.
