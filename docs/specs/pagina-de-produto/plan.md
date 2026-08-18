# Página de Produto (PDP) — Plano

## Contexto e objetivo

A página de produto (`templates/product.tpl` + `snipplets/product/*`) nunca
foi tocada desde a importação inicial do tema — roda 100% no markup "stock"
da Nuvemshop (grid Bootstrap `container`/`row`/`col-md-7`, botões
`btn btn-primary`), sem nenhuma classe Tailwind, dirigida inteiramente pelo
JS legado jQuery (`static/js/store.js.tpl`). Não existe
`__src/js/modules/product/`, não existe seção "PRODUCT" em `app.css`.

Objetivo desta feature: redesenhar a PDP (galeria de fotos, zoom
fullscreen, nome/breadcrumb/preço, seleção de variantes, quantidade,
calculadora de frete, barra fixa de compra, accordions de descrição/tabela
de medidas) seguindo o layout do Figma ("Site Romã - 2025", fileKey
`eF7t9XSEDXRSKqS2vmriUs`, frame "Product" node `5:607` + frame "Product
Image Details" node `52:2434`), no mesmo padrão de acabamento (Tailwind v4
+ módulos JS custom vanilla) já aplicado em `templates/category.tpl` e na
home.

**O carrossel "Leve junto" (relacionados/complementares) fica FORA desta
feature, por decisão explícita do usuário** — ver detalhamento na seção de
Riscos. `snipplets/product/product-related.tpl` permanece como está hoje
(Bootstrap/legado) até que essa decisão seja revisitada.

**Correção (descoberta depois da primeira versão deste plano)**: existe sim
um desktop desenhado para a PDP. Ele não aparece na listagem de páginas de
topo do arquivo Figma (só lista "Mobile" e "Components") porque vive
aninhado dentro do arquivo, num node chamado "Desktop" (id `79:3479`) que
não é uma página de primeiro nível — só foi encontrado ao abrir o link
direto que o usuário passou (`node-id=131-1503`). Dentro desse "Desktop"
existem frames reais de 1440px para Home e Categoria, e — mais importante —
um frame **"Desktop - 3" (node `131:1503`)** que é o desenho completo da
PDP em desktop, não uma adaptação minha. Existe também um frame "Product"
duplicado dentro do mesmo "Desktop" (node `131:3164`) que é só uma cópia
abandonada de 393px do mobile (confirmado por screenshot, pixel a pixel
igual ao mobile) — esse aí sim não vale nada como referência; o correto é
`131:1503`.

O layout real do desktop (extraído via `get_design_context` em `131:1503`)
é **fundamentalmente diferente** do que a primeira versão deste plano
assumia (não é "galeria+buy box lado a lado, e o resto em seções largas
abaixo"). Ver decisão #6 para o detalhamento exato. Home/categoria em si
não fazem parte desta feature — só uso os frames desktop deles como
confirmação de convenções globais já compartilhadas (header, footer,
paddings de página).

## Domínios/arquivos afetados

- `templates/product.tpl`
- `snipplets/product/*.tpl` (arquivos reescritos ou substituídos:
  `product-image.tpl`, `product-form.tpl`, `product-variants.tpl`,
  `product-quantity.tpl`; `product-payment-details.tpl` e
  `product-video.tpl` seguem intocados)
- `snipplets/product/product-related.tpl` — **fica fora do escopo desta
  feature** (ver Riscos) — não é tocado por nenhuma spec numerada.
- `snipplets/shipping/shipping-calculator.tpl` (compartilhado com o
  carrinho — mudanças cirúrgicas, ver riscos)
- Novo contexto `__src/js/modules/product/` (não existe hoje)
- `__src/js/index.js` (novos imports + atualização da contagem A3)
- `__src/css/app.css` (nova seção "PRODUCT PAGE STYLES")
- `docs/architecture-map.md` (atualizado ao final, spec 10)

## Riscos e zonas de não-modificação

- **`static/js/store.js.tpl` NUNCA é editado diretamente** (F1/A4 do
  contrato de arquitetura). Onde a compatibilidade com o legado é mantida
  (galeria Swiper, quantidade, frete), isso se dá preservando as classes
  `js-*` e atributos `data-*` que o legado já lê — nunca editando o script.
- **`snipplets/shipping/shipping-calculator.tpl` é compartilhado com
  `snipplets/cart-totals.tpl`** (página de carrinho). A spec 06 precisa
  validar visualmente as duas telas depois de mexer nele.
- **Fancybox (`data-fancybox="product-gallery"`) é usado em mais de um
  lugar**: além do link de cada foto em `product-image.tpl`, também é usado
  pelo trigger de vídeo em `snipplets/video-item.tpl`, incluído tanto por
  `snipplets/product/product-video.tpl` (vídeo dentro da galeria da PDP)
  quanto por `snipplets/home/home-video.tpl` (seção de vídeo da home). A
  spec 03 remove o atributo `data-fancybox` **apenas** dos links de foto —
  o bind global do Fancybox continua ativo no projeto para o trigger de
  vídeo, que não é tocado.
- **Decisão de reimplementar a seleção de variantes em JS custom** (em vez
  de manter `LS.changeVariant`/legado por baixo de uma casca Tailwind) foi
  uma escolha explícita do usuário, ciente do trade-off: ganha-se um
  componente 100% sob controle do projeto (mesmo padrão do quickbuy dos
  cards, `__src/js/modules/system/item-card-quickbuy.js`), mas os
  componentes de plataforma (`installments`, `promotions-details`) não são
  recalculados dinamicamente ao trocar de variante — eles continuam
  renderizados server-side para a variante *default* no load da página. Ver
  spec 04 para o detalhamento e a verificação empírica necessária dos
  campos de `variants_object`.
- **Spec 07 (add-to-cart via fetch) precisa isolar as classes do botão**
  para não duplicar a notificação de "produto adicionado" que o legado já
  dispara em `.js-addtocart` (`store.js.tpl:1724`).
- **"Leve junto" (relacionados/complementares) adiado para depois desta
  feature, por decisão do usuário.** Motivo: esse carrossel vai ser
  reaproveitado como componente em outras partes do site (não é só um
  bloco específico da PDP), então merece um desenho próprio de
  reutilização (provavelmente uma feature/spec-slug separada, decidindo
  onde o componente "mora" e como outras páginas o consomem) em vez de ser
  resolvido de passagem dentro da spec 09 original, que já tinha ficado
  presa a um risco técnico específico da PDP (o `desktopColumns` hardcoded
  do Swiper legado confinado à coluna de 564px — ver decisão de desktop
  abaixo). A spec `09-carrossel-relacionados.md` continua existindo neste
  diretório como registro do que foi investigado (útil quando essa feature
  futura for planejada), mas está com `status: blocked` e **não faz parte
  da sequência ativa** — `product-related.tpl` fica como está (Bootstrap)
  até lá, e a spec `10-cleanup-e-arquitetura` não depende mais dela nem
  audita esse arquivo.

  **Efeito colateral visual aceito**: hoje `templates/product.tpl` inclui
  `product-related.tpl` **fora** do bloco `#single-product`, como uma
  seção larga separada, no final da página (não aninhada dentro do que
  vai virar a coluna direita de 564px). Como nenhuma spec ativa move esse
  include, o resultado esperado é: a área do produto (galeria + coluna de
  compra) fica no novo visual Tailwind/desktop de 2 colunas, e "Leve
  junto" continua aparecendo **depois**, largura cheia, no visual
  Bootstrap antigo — uma inconsistência de estilo entre seções, não um bug
  de layout. Isso é esperado e aceito até a feature futura do componente
  reutilizável.
- **Estrutura real do desktop (Figma node `131:1503`, "Desktop - 3") —
  substitui qualquer suposição anterior de "grid 2 colunas + seções largas
  abaixo"**:
  - Uma linha, **sem padding lateral** nesta seção (diferente do resto do
    site, que usa `px-16`/64px — aqui a galeria vai até a borda): coluna
    esquerda de **876px** (galeria) + coluna direita de **564px** (tudo o
    resto), `876 + 564 = 1440`, sem gap entre elas.
  - **Coluna esquerda — galeria**: NÃO é o swiper do mobile. É uma
    **grade estática de 2 colunas com TODAS as fotos** (cada célula
    438px = 876/2, `flex-wrap`, sem paginação/setas), container com
    `overflow-y-auto`. Badges só sobre a primeira foto.
  - **Coluna direita — tudo empilhado, nesta ordem**: breadcrumb → título +
    preço/desconto/pix → **bloco título/preço/tamanho à esquerda com o
    stepper de quantidade AO LADO, na mesma linha** (diferente do mobile,
    onde quantidade vem abaixo, largura cheia) → botão "Comprar" (largura
    cheia da coluna, **sem ser fixo/sticky**, no fluxo normal) → barra de
    progresso "Faltam X itens para 15% OFF" (também no fluxo normal, logo
    abaixo) → carrossel "Leve junto" **confinado aos 564px da coluna**
    (cards de 234px iguais ao mobile, só ~2,3 visíveis por vez) →
    calculadora de frete → accordion "Descrição" (aberto) → accordion
    "Tabela de Medidas" (fechado) → `seedDivider`.
  - **Sem barra fixa de compra no desktop**: o botão "Comprar" e a
    progress bar fazem parte do fluxo normal da coluna direita — a spec 07
    trata `product-sticky-buy-bar.tpl` como **um componente só, com
    posicionamento responsivo** (`fixed bottom-0` até o breakpoint
    desktop, `static`/em fluxo dentro da coluna direita a partir dele), não
    dois componentes separados.
  - **Breakpoint**: como o Figma é literalmente 1440px e não existe mockup
    de tablet, a troca de 1 para 2 colunas deve acontecer em `lg:`
    (1024px), não em `md:` (768px) — 564px de coluna + galeria de 2
    colunas não cabe bem numa faixa de 768-1023px. `md:` continua livre
    para ajustes menores de espaçamento/tipografia dentro da faixa tablet.
  - **Risco novo**: o Swiper legado do "Leve junto"
    (`.js-swiper-related`/`.js-swiper-complementary`) usa, a partir de
    768px, `slidesPerView: desktopColumns` — `desktopColumns` é
    **hardcoded dentro do próprio `store.js.tpl`** (linha ~673/2429) como
    `3` ou `4` (de `settings.grid_columns`, uma config sitewide, não
    específica desta seção), pensado para uma seção larga — não para caber
    em 564px. Reaproveitar sem ajuste espremeria 3-4 cards onde o Figma
    mostra ~2,3 cards de 234px. Como `store.js.tpl` não pode ser editado
    (F1/A4), a spec 09 precisa resolver isso só com CSS no preview real; se
    não for possível, **parar e perguntar ao usuário** antes de introduzir
    JS custom ali (reverteria a decisão de "sem JS novo" da spec 09).
  - Header (barra de anúncio + nav "Produtos/Sobre/Suporte/Personalize") e
    footer no desktop já são os componentes globais existentes — nada novo
    para a PDP aqui, só confirmação visual via os frames "Desktop -
    3"/"Desktop - 4" do Figma.
- **Correção descoberta ao detalhar as specs**: a galeria principal de fotos
  não pode continuar no Swiper legado (`.js-swiper-product`, criado por
  `createSwiper()` em `store.js.tpl:1603`) porque a troca de imagem por
  variante hoje só acontece via `LS.registerOnChangeVariant`
  (`store.js.tpl:1662-1669`), que só dispara quando `LS.changeVariant` é
  chamado — e a spec 04 abandona esse fluxo completamente. Sem um dono
  custom da galeria, a spec 04 não teria como trocar a imagem ativa. Por
  isso a spec 02 substitui a galeria por um módulo custom
  (`product-gallery.js`, Swiper via `window.Swiper` global, mesmo padrão de
  `product-carousel.js`), usando um novo nome de classe para o container
  (ex.: `.js-product-gallery`) — **nunca reaproveitar
  `.js-swiper-product`/`.js-swiper-product-pagination`/
  `.js-swiper-product-next`/`.js-swiper-product-prev`**, para que o
  `createSwiper('.js-swiper-product', ...)` legado não encontre nada e não
  crie um segundo Swiper concorrente no mesmo elemento. O módulo expõe um
  `window.*` (ex.: `window.setProductGalleryImage(imagePosition)`) para a
  spec 04 consumir.

## Lista de specs

1. **01-fundacao-layout-e-preco** — estrutura de 2 colunas (876px/564px,
   sem gap, sem padding lateral) a partir de `lg:`, mobile empilhado abaixo
   disso; nome/breadcrumb/bloco de preço, mantendo os `component(...)` de
   plataforma (subscriptions/promotions/installments) intocados. Ver
   estrutura real do desktop nos riscos do `plan.md`.
2. **02-galeria-de-fotos** — `product-image.tpl` em Tailwind com um novo
   módulo `product-gallery.js` (Swiper custom — o Swiper legado da galeria
   precisa ser substituído para que as specs 03/04 consigam controlá-lo via
   `window.*`). No mobile/tablet continua sendo um carrossel; a partir de
   `lg:` vira uma grade estática de 2 colunas com todas as fotos (sem
   swiper) — dois markups condicionais por breakpoint, não uma adaptação
   do mesmo carrossel.
3. **03-modal-zoom-fotos** — novo módulo `product-gallery-zoom.js` +
   snipplet de overlay fullscreen para o zoom das fotos.
4. **04-selecao-de-variantes** — novo módulo `product-variants.js` (padrão
   quickbuy) + pills/swatches Tailwind, abandonando o `<select>` legado. A
   partir de `lg:`, o stepper de quantidade (spec 05) fica ao lado do bloco
   de tamanho na mesma linha, não abaixo (diferente do mobile).
5. **05-quantidade** — `product-quantity.tpl` reestilizado, mesma lógica
   legada.
6. **06-calculadora-de-frete** — novo `snipplets/product/product-shipping-
   calculator.tpl` (cópia funcional isolada, Tailwind), em vez de editar o
   arquivo compartilhado com o carrinho — mais seguro que interleaving de
   dois sistemas visuais no mesmo arquivo. Ver nota de risco sobre
   comportamento legado incerto do botão de calcular na spec.
7. **07-barra-fixa-de-compra** — um componente só, com posicionamento
   responsivo: `fixed bottom-0` (mobile/tablet) até `lg:`, e em fluxo
   normal dentro da coluna direita a partir daí (sem esconder/duplicar) —
   preço + CTA + `product-add-to-cart.js` (fetch, toast, cart-drawer) +
   progress bar reaproveitando `cart-drawer-progress-bars.tpl`.
8. **08-accordions** — módulo genérico de accordion + seções Descrição/
   Tabela de Medidas (reaproveitando `settings.size_guide_url`).
9. ~~**09-carrossel-relacionados**~~ — **adiado, fora da sequência ativa**
   (`status: blocked`). "Leve junto" vai virar um componente reutilizável
   em outras partes do site, então será desenhado numa feature própria,
   não dentro do redesenho da PDP. O arquivo da spec continua no diretório
   só como registro da investigação já feita (o risco do `desktopColumns`
   hardcoded do Swiper legado, confinado à coluna de 564px, é relevante
   para quando essa feature futura for planejada). `product-related.tpl`
   não é tocado por esta feature.
10. **10-cleanup-e-arquitetura** — remoção de resíduos Bootstrap/Fancybox,
    atualização de `docs/architecture-map.md`. Não depende mais da spec 09
    e não audita `product-related.tpl` (fora de escopo). Passa a depender
    também das specs 11 e 12.
11. **11-barra-de-compra-mobile** — reimplementa a barra fixa de compra do
    mobile fiel ao Figma `addCartContainer` (node `52:1686`, 116px: botão
    auto-width à direita do preço, badges como texto verde-limão inline,
    progresso compacto) e corrige a cor do botão para `bg-secondary`, a
    mesma do checkout do cart drawer. Surgiu da validação da spec 07 no
    preview: desktop aprovado, mobile com ~250px de barra fixa por ter
    desviado do desenho.
12. **12-fundo-da-pagina** — a PDP passa a renderizar sobre
    `--background-color` (token `bg-bg`) em vez do branco padrão do
    navegador, como a categoria já faz. Pedido do usuário na validação.

Cada spec é implementada e validada individualmente via `/implement-spec`,
na ordem acima (respeitando `depends_on` de cada uma).
