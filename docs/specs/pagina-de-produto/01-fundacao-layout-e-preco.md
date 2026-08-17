---
feature: pagina-de-produto
spec: 01-fundacao-layout-e-preco
status: done
depends_on: []
---

## Objetivo

Substituir o grid Bootstrap de `templates/product.tpl` pela estrutura real
do Figma — 1 coluna empilhada no mobile/tablet, e a partir de `lg:` duas
colunas fixas (876px galeria + 564px "tudo o resto", sem gap, sem padding
lateral de página) — e reescrever o cabeçalho de `snipplets/product/
product-form.tpl` (nome, breadcrumb, bloco de preço) no mesmo padrão
visual/tipográfico do Figma, sem alterar nenhuma outra seção da página
nesta spec.

**Referência real de desktop**: Figma node `131:1503` ("Desktop - 3", no
mesmo arquivo `eF7t9XSEDXRSKqS2vmriUs`) — é um desenho completo da PDP em
1440px, não uma inferência. Extraído via `get_design_context`: a seção da
galeria+conteúdo é `<div class="flex items-start w-full">` com dois filhos
diretos, sem `gap` entre eles e **sem padding lateral** (diferente do resto
do site, que usa `px-16`/64px) — filho 1 com `w-[876px]` (galeria), filho 2
com `w-[564px]` (tudo o resto, empilhado verticalmente: opções do produto,
CTA, progress bar, "Leve junto", frete, accordions — cada um implementado
nas specs seguintes). `876 + 564 = 1440`. Essa proporção (~61%/39%) é o que
esta spec precisa reproduzir; não usar um `grid-cols-2` 50/50 genérico.

## Escopo

- `templates/product.tpl` — arquivo inteiro.
- `snipplets/product/product-form.tpl` — **apenas** o trecho do embed
  `page-header.tpl` (linhas 1-5 atuais) até o fim do bloco
  `promotions-details` (linha 59 atual, inclusive). O restante do arquivo
  (subscription-selector, variantes, quantidade, CTA, frete, payment
  details, social share, descrição) permanece incluído exatamente como está
  hoje — **não reescrever, não remover, não reordenar** essas seções nesta
  spec, mesmo que fiquem visualmente "Bootstrap dentro de Tailwind" por
  enquanto (será resolvido pelas specs seguintes).
- Proibido nesta spec: tocar `snipplets/page-header.tpl` (é compartilhado
  com outros templates — `category`, páginas genéricas — via o mesmo
  embed), tocar `snipplets/breadcrumbs.tpl` (já é Tailwind e já é
  consumido por `category.tpl` da mesma forma), tocar
  `snipplets/product/product-variants.tpl`, `product-quantity.tpl`,
  `product-related.tpl`, `product-image.tpl`, `shipping/*`.
  Qualquer necessidade de tocar esses arquivos exige parar e perguntar ao
  usuário antes de prosseguir.

## Critérios de aceite

- [x] `templates/product.tpl` usa `flex flex-col lg:flex-row lg:items-start`
      (ou equivalente) no lugar de `container`/`row`/`col-12 col-md-7`/
      `col`, com o filho da galeria em `lg:w-[876px]` e o filho do
      restante do conteúdo em `lg:w-[564px]` (ou proporção equivalente via
      `lg:basis-*`) — **sem** `gap`/padding lateral entre os dois a partir
      de `lg:`. Abaixo de `lg:`, 1 coluna empilhada, largura cheia. Nenhuma
      classe Bootstrap de grid restante no arquivo. O breakpoint é `lg:`
      (1024px), não `md:` — não existe mockup de tablet, e uma coluna de
      564px + galeria de 2 colunas não cabe bem entre 768-1023px.
- [x] `product-form.tpl` para de usar `{% embed "snipplets/page-header.tpl"
      %}` e passa a chamar `{% include 'snipplets/breadcrumbs.tpl' %}`
      diretamente, seguido de um `<h1>` com a tipografia do Figma (Larken
      ExtraBold, ~24px, cor via token `text-secondary`), preservando
      **exatamente** a classe `js-product-name` e o atributo
      `data-store="product-name-{{ product.id }}"` no `<h1>` (lidos por
      `static/js/store.js.tpl:1759` para tracking/analytics no add-to-cart —
      remover quebraria isso silenciosamente).
- [x] Antes de assumir que a variável `breadcrumbs` está disponível no
      contexto de `product.tpl` da mesma forma que em `category.tpl`,
      verificar no preview da Nuvemshop que `snipplets/breadcrumbs.tpl`
      renderiza a trilha correta (Categoria / Subcategoria / Nome do
      produto) na PDP — se não estiver disponível, usar a mesma fonte de
      dado que `page-header.tpl`/`breadcrumbs.tpl` já usavam antes da
      mudança (não inventar uma variável nova). Confirmado pelo usuário no
      preview real (via `/ftp-deploy`): o breadcrumb está disponível e
      renderiza na PDP.
- [x] Bloco de preço (`.js-price-container`, `data-store="product-price-
      {{ product.id }}"`) reestilizado em Tailwind (preço atual em destaque
      + preço "de" riscado, no padrão visual de `snipplets/grid/item-
      card.tpl`), preservando **exatamente** as classes/atributos
      `js-price-container`, `js-compare-price-display`,
      `js-price-display`, `id="compare_price_display"`,
      `id="price_display"`, `data-product-price="{{ product.price }}"` —
      todos lidos por `store.js.tpl` em múltiplos pontos (linhas ~959,
      1270-1285, 1410-1411, 1760-1764) para conversão de moeda, tracking de
      add-to-cart e (até a spec 04 entrar em vigor) atualização de preço por
      variante.
- [x] `component('price-discount-disclaimer', ...)`,
      `component('price-without-taxes', ...)`,
      `component('payment-discount-price', ...)`,
      `component('subscriptions/subscription-price', ...)` e
      `component('promotions-details', ...)` continuam sendo chamados com
      os mesmos parâmetros — só as classes passadas em
      `container_classes`/`subscription_classes`/`promotions_details_classes`
      podem trocar de Bootstrap para Tailwind (essas classes são
      injetadas pelo componente da plataforma no HTML gerado, então trocá-
      las é seguro e não quebra a lógica).
- [x] Página renderiza sem erros no preview da Nuvemshop com o restante da
      PDP (variantes, quantidade, CTA, frete, relacionados) intacto e
      funcional exatamente como estava antes desta spec. Confirmado pelo
      usuário: sem erros aparentes no preview após `/ftp-deploy`.
- [x] `npm run build` executado e bundle/CSS atualizados.

## Invariantes aplicáveis

- **A8/F4** — nenhuma cor hardcoded; usar tokens `@theme` (`text-secondary`,
  `bg-bg`, etc.) ou `var(--accent-color)`.
- **A10** — nenhum snipplet novo é criado nesta spec; se algum vier a ser
  necessário, deve ir em `snipplets/product/`.
- **T5** — não inventar dado de produto que não venha do template/contexto
  já fornecido pela plataforma.
- **F1/A4** — não editar `static/js/store.js.tpl`.

## Referências de padrão

- **Figma node `131:1503`** ("Desktop - 3") — layout real de desktop da
  PDP, ver `plan.md` para o detalhamento completo extraído via
  `get_design_context`.
- `templates/category.tpl` (linhas 61-73, 162-163) — grid Tailwind
  responsivo `md:`/`lg:`, uso de `{% include 'snipplets/breadcrumbs.tpl' %}`
  diretamente sem passar por wrapper Bootstrap.
- `snipplets/grid/item-card.tpl` (bloco "Price Container", linhas 109-125) —
  padrão visual de preço atual + compare-at riscado em Tailwind.
- `snipplets/breadcrumbs.tpl` — componente de breadcrumb já pronto, mesmo
  usado por `category.tpl`.
