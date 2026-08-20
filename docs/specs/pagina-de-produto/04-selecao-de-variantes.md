---
feature: pagina-de-produto
spec: 04-selecao-de-variantes
status: done
depends_on: ["01-fundacao-layout-e-preco", "02-galeria-de-fotos"]
---

<!-- Validado no preview real da Nuvemshop em 2026-08-18: seleção de
variantes funcionando (clique/seleção, troca de foto, add-to-cart com a
variante correta). -->

## Objetivo

Substituir a seleção de tamanho/cor da PDP (hoje um `<select>` nativo com
skin `.js-insta-variant` dirigida por `LS.changeVariant`) por pills/swatches
Tailwind controlados por um novo módulo custom `__src/js/modules/product/
product-variants.js`, no mesmo padrão do quickbuy dos cards
(`item-card-quickbuy.js`): stock-aware, atualiza preço/desconto exibidos e
troca a imagem principal da galeria — decisão explícita do usuário (ver
`plan.md`, seção de riscos, para o trade-off registrado).

## Escopo

- `snipplets/product/product-variants.tpl` — reescrita completa (remove o
  embed de `snipplets/forms/form-select.tpl`, o `<select
  class="js-variation-option">` e os botões `.js-insta-variant`).
- Novo: `__src/js/modules/product/product-variants.js`.
- `__src/js/index.js` — novo import + atualização da contagem A3.
- Proibido nesta spec: `snipplets/product/product-quantity.tpl`,
  `snipplets/product/product-form.tpl` fora do `{% include
  "snipplets/product/product-variants.tpl" ... %}` (linha que já existe,
  só passa a não receber mais `show_size_guide: true` se esse parâmetro
  deixar de fazer sentido — decidir na implementação), calculadora de
  frete, CTA de compra (spec 07 cuida do add-to-cart em si).

## Verificação empírica obrigatória (fazer ANTES de codar a lógica)

- [x] Abrir o preview da Nuvemshop com um produto com variações e inspecionar
      o conteúdo real de `data-variants` em `#single-product`
      (`{{ product.variants_object | json_encode }}`, já presente em
      `templates/product.tpl` linha 2 — não precisa criar nada novo) para
      confirmar quais campos cada variante realmente tem disponíveis (ex.:
      `id`, `optionN`, `available`, `price`/`price_number`,
      `compare_at_price`, `promotional_price`, `image_id`). O módulo só
      pode usar campos confirmados como presentes — não assumir a partir da
      documentação pública da API REST da Nuvemshop, que pode divergir do
      filtro do tema.
      **Verificado**: JSON real inspecionado num produto de teste
      (`camiseta-estonada-brita`, loja de dev) via fetch headless. Campos
      confirmados por variante: `product_id`, `price_short`, `price_long`,
      `price_number`, `price_number_raw`, `price_with_payment_discount_short`,
      `price_without_taxes`, `compare_at_price_short`,
      `compare_at_price_long`, `compare_at_price_number`,
      `has_promotional_price`, `promotional_price_short`,
      `promotional_price_number`, `stock`, `sku`, `available`, `is_visible`,
      `contact`, `option0`/`option1`/`option2`, `id`, `image` (índice
      numérico, não `image_id`), `image_url`, `installments_data`,
      `show_payment_discount_disclaimer`, `popup_discount_visibility`.
- [x] Se `image_id` (ou equivalente) não estiver presente no JSON, a troca
      de imagem por variante fica fora do escopo desta spec — documentar
      isso como limitação conhecida em vez de improvisar uma correlação
      frágil por nome de opção.
      **Não se aplica**: o campo existe, só com nome diferente do
      assumido — `image` (posição numérica), não `image_id`. Compatível
      diretamente com `window.setProductGalleryImage(imagePosition)` da
      spec 02/03, que já espera um índice posicional
      (`data-image-position`). Troca de imagem por variante implementada
      normalmente, sem limitação.

## Layout desktop (confirmado no Figma, não é inferência)

No Figma node `131:1503` ("Desktop - 3"), a partir de `lg:` o bloco de
tamanho e o stepper de quantidade (spec 05) ficam **lado a lado, na mesma
linha** (`flex items-start` envolvendo os dois: título/preço/tamanho numa
sub-coluna à esquerda, `QuantityContainer` à direita) — diferente do
mobile, onde quantidade vem **abaixo** do tamanho, largura cheia. Esta
spec é responsável só pelo bloco de tamanho/cor em si; a spec 05
(quantidade) deve ser implementada de forma que os dois blocos possam ser
colocados lado a lado em `lg:` via o contêiner pai (definido nesta spec ou
ajustado quando a spec 05 rodar — coordenar para não duplicar o wrapper).

## Critérios de aceite

- [ ] **PENDENTE — requer preview real.** UI de seleção: pills retangulares
      para tamanho (40/42/44/46/48/50) e swatches para cor, no padrão
      visual das pills de `snipplets/grid/item-card.tpl`
      (`.js-quickbuy-pill`), adaptado para o tamanho maior da PDP mostrado
      no Figma (`SizeOptions`/`TextButton`) — implementado (pills
      retangulares `min-w-12 h-11 px-4 rounded-lg`, swatches circulares
      `w-10 h-10 rounded-full`), mas o encaixe pixel-a-pixel com o Figma só
      pode ser confirmado visualmente.
- [x] `product-variants.js` segue o padrão de `item-card-quickbuy.js`:
      guard `if (!element) return;` (A2), lê o JSON de `data-variants`, RE-
      DESABILITA (`opacity-40 pointer-events-none line-through` ou
      equivalente) combinações sem estoque com a mesma lógica de
      `updateStockStatus`, seleciona a primeira opção disponível por
      padrão. Verificado por leitura de código
      (`__src/js/modules/product/product-variants.js`).
- [x] Ao trocar a seleção, o módulo escreve o novo preço/preço riscado
      diretamente nos elementos `#price_display`
      (`.js-price-display`)/`#compare_price_display`
      (`.js-compare-price-display`) criados na spec 01 — preservando essas
      classes/IDs para que qualquer leitura legada posterior (ex.
      `store.js.tpl:1760-1764`, tracking de add-to-cart) continue vendo o
      preço correto da variante selecionada. Verificado por leitura de
      código; `store.js.tpl:1758` lê `.js-price-display` via `.text()`,
      compatível com `textContent` usado no módulo.
- [x] Ao trocar a seleção, se a variante tiver imagem associada (ver
      verificação empírica acima), chama
      `window.setProductGalleryImage?.(...)` (função exposta pela spec 02)
      para sincronizar a galeria — nunca importa `product-gallery.js`
      diretamente (F9). Verificado por leitura de código.
- [x] Nenhum `<select>` nem classe `js-variation-option`/`js-insta-variant`
      permanece no HTML renderizado — a partir desta spec, `LS.changeVariant`
      nunca é acionado pela PDP. Verificado: `grep` em
      `product-variants.tpl` não retorna nenhuma ocorrência dessas classes;
      `store.js.tpl:1353`/`1527` só dispara `LS.changeVariant` via binds
      delegados a essas classes, que não têm mais nenhum elemento
      correspondente no DOM.
- [x] O link "Tabela de Medidas" aponta para o accordion da spec 08 (por
      exemplo via `href="#tabela-de-medidas"` ou `data-scroll-target`) — se
      a spec 08 ainda não tiver sido implementada, o link pode
      simplesmente não fazer nada (não é regressão, é uma feature aditiva
      que se completa depois); não reintroduzir o modal antigo de
      `product-variants.tpl` legado para isso. Implementado como
      `href="#tabela-de-medidas"`; spec 08 ainda não existe, então hoje é
      um link inerte (esperado).
- [x] Se o produto não tiver variações (`product.variations` vazio), a
      seção inteira não renderiza (mesma condicional já usada hoje).
      `product-form.tpl` (não tocado por esta spec) já envolve o include em
      `{% if product.variations %}`.
- [x] `npm run build` executado sem erros (rodado nesta implementação).

## Invariantes aplicáveis

- A1/A2/A3/F6 — módulo novo no contexto `product/`.
- A8/F4 — badges/estado "sem estoque" sem cor hardcoded.
- D1/T5 — todo dado de variante vem do JSON já renderizado no DOM; nenhum
  fetch de API própria.
- F9/R1 — comunicação com a galeria (spec 02) só via `window.*`.
- A6/L4 — `lucide.createIcons()` se houver ícone dinâmico novo.

## Referências de padrão

- **Figma node `131:1503`** ("Desktop - 3") — layout real do bloco
  tamanho+quantidade lado a lado no desktop.
- `__src/js/modules/system/item-card-quickbuy.js` — padrão completo a
  replicar: leitura do JSON de variantes, `updateStockStatus`, seleção de
  pill, `data-selected`.
- `snipplets/grid/item-card.tpl` — markup das pills/dropdown de variante já
  em Tailwind.
- `snipplets/product/product-variants.tpl` (versão atual, antes desta
  spec) — onde hoje está a resolução de `settings.size_guide_url` por
  handle de página, reaproveitada como referência para a spec 08 (não
  para esta).
