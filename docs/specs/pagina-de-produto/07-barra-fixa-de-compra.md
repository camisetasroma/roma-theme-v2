---
feature: pagina-de-produto
spec: 07-barra-fixa-de-compra
status: pending
depends_on: ["01-fundacao-layout-e-preco", "04-selecao-de-variantes", "05-quantidade"]
---

<!-- Implementação completa e `npm run build` ok. Status segue "pending"
(mesmo motivo das specs 02/03/04): falta validar no preview real da
Nuvemshop (encaixe pixel-a-pixel do backdrop-blur/posicionamento
responsivo, fetch de add-to-cart de fato adicionando o item, toast +
cart-drawer atualizando, badges de parcelamento/pix com dados reais de
produto, estados contact/catalog/nostock). Marcar "done" após essa
validação manual. -->

## Objetivo

Implementar o bloco de compra do Figma (`addCartContainer`): preço atual +
riscado + badges "3x Sem Juros"/"5% OFF no pix" + botão "Comprar" + barra de
progresso de desconto progressivo — e trocar o envio do formulário de
compra para `fetch` (sem reload), integrando com toast e cart-drawer
modernos, no mesmo padrão de `item-card-quickbuy.js`.

**Correção de escopo (confirmado no Figma node `131:1503`, "Desktop -
3")**: isto **não** é "barra fixa no mobile + algo diferente no desktop" —
é **um único componente**, cujo posicionamento muda por breakpoint: `fixed
bottom-0` (com backdrop-blur) do mobile até `lg:`, e a partir de `lg:` ele
renderiza **em fluxo normal** (não fixo, não sticky) dentro da coluna
direita de 564px da spec 01, logo depois do bloco de tamanho/quantidade
(spec 04/05) e antes do carrossel "Leve junto" (spec 09) — exatamente como
aparece no Figma desktop. Implementar como o mesmo markup com classes
responsivas (ex.: `fixed bottom-0 left-0 w-full lg:static lg:w-full`), não
como dois componentes/dois includes separados.

## Escopo

- Novo: `snipplets/product/product-sticky-buy-bar.tpl`.
- Novo: `__src/js/modules/product/product-add-to-cart.js`.
- `snipplets/product/product-form.tpl` — troca do bloco atual do
  `<input type="submit" class="js-addtocart js-prod-submit-form" ...>`
  (dentro de `<form id="product_form" ...>`) para que o submit seja
  interceptado pelo novo módulo. O restante do `<form>` (variantes,
  quantidade, subscription-selector, frete) permanece como já estiver
  depois das specs anteriores.
- `__src/js/index.js` — novo import + atualização da contagem A3.
- `__src/css/app.css` — estilos do backdrop-blur/z-index da barra fixa
  (reaproveitando tokens `--z-*` já existentes, se houver algum próximo do
  necessário; senão adicionar um novo seguindo o padrão existente).
- Proibido nesta spec: `snipplets/product/product-payment-details.tpl`
  (modal de parcelamento, já usa o modal system moderno — não mexer),
  `snipplets/social/social-share.tpl`.

## Critérios de aceite

- [ ] `product-sticky-buy-bar.tpl` é fixa no rodapé (`fixed bottom-0`) com
      `backdrop-blur` e fundo semi-transparente via `color-mix(in srgb,
      var(--background-color) 85%, transparent)` (nunca
      `rgba(255,255,246,0.85)` hardcoded — A8/F4) do mobile até `lg:`; a
      partir de `lg:` vira um bloco normal (sem `fixed`, sem blur/fundo
      diferenciado — mesmo fundo da página) dentro da coluna direita da
      spec 01, na posição confirmada pelo Figma (depois de tamanho/
      quantidade, antes de "Leve junto"). Mostra preço atual + riscado
      (lendo os mesmos elementos
      `.js-price-display`/`.js-compare-price-display` da spec 01/04, não
      duplicando o dado) + badges "3x Sem Juros"/"X% OFF no pix" (a partir
      de `product.installments_info_from_any_variant`/
      `product.maxPaymentDiscount`, já disponíveis no contexto Twig, como
      hoje em `product-form.tpl`) + botão "Comprar".
- [ ] Barra de progresso de desconto progressivo reaproveita
      **diretamente** `{% snipplet "cart/cart-drawer-progress-bars.tpl" %}`
      (mesmas configs `settings.cart_discount_bar`/tiers do carrinho) —
      não recriar a lógica de cálculo de progresso.
- [ ] `product-add-to-cart.js` intercepta o `submit` de `#product_form`
      (`e.preventDefault()`), monta `FormData(form)` (herda
      automaticamente `add_to_cart`, `quantity`, e os campos de variação
      que o módulo da spec 04 escrever no form — ver nota abaixo) e faz
      `fetch(store.cart_url, {method:'POST', body: formData,
      headers:{'X-Requested-With':'XMLHttpRequest'}})`, mesmo padrão de
      `item-card-quickbuy.js`.
- [ ] **Nota de integração com a spec 04**: como a seleção de variantes
      passou a ser um componente JS custom sem `<select>` (spec 04), o
      módulo desta spec precisa de um jeito de saber qual variante está
      selecionada ao montar o `FormData`. Usar o mesmo formato de
      `item-card-quickbuy.js` (`variation[variationId]=optionId`), lendo o
      estado a partir de atributos `data-selected="true"` nas pills (não
      reimplementar o estado, só ler o que a spec 04 já mantém no DOM).
- [ ] Ao sucesso: chama `window.showProductToast?.({image, name, price,
      quantity, variation})` e `window.onCartUpdate?.()` — sem reload de
      página.
- [ ] O clique no CTA da barra fixa **não** duplica a notificação legada de
      "produto adicionado" — a classe `.js-addtocart` (lida por
      `store.js.tpl:1724` para sua própria UI de "Ya agregaste este
      producto") não deve estar presente no novo botão, ou o listener
      legado correspondente deve ser neutralizado trocando esse contrato de
      classe (documentar a escolha feita).
- [ ] Estados `cart`/`contact`/`nostock`/`catalog` (já calculados em
      `product-form.tpl` via `{% set state = ... %}` e `texts[state]`)
      continuam determinando o texto do botão e se ele fica desabilitado —
      reaproveitar a mesma variável `state`/`texts`, não recriar.
- [ ] `lucide.createIcons()` se houver ícone dinâmico novo (A6).
- [ ] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A1/A2/A3/F6 — módulo novo no contexto `product/`.
- A5/S2 — usa `window.showProductToast`/`window.onCartUpdate` já
  existentes; não inventa globals novos sem necessidade real.
- A8/F4 — sem cor hardcoded no backdrop.
- D1/T5 — nenhuma chamada a `LS.*` fora do permitido (fetch para
  `store.cart_url` é o padrão já usado por `item-card-quickbuy.js`, não
  `LS.addItem` — manter consistência com essa referência).
- F1/A4 — `static/js/store.js.tpl` não é editado.

## Referências de padrão

- **Figma node `131:1503`** ("Desktop - 3") — confirma que o CTA/progress
  bar não são fixos no desktop, e sua posição exata na coluna direita.
- `__src/js/modules/system/item-card-quickbuy.js` (bloco `addBtn` em
  diante) — `FormData`, `fetch`, `window.showProductToast`,
  `window.onCartUpdate`, tratamento de erro/disable durante request.
- `snipplets/cart/cart-drawer-progress-bars.tpl` — barra de progresso a
  reaproveitar tal como está.
- `snipplets/product/product-form.tpl` (trecho `{% set state = ... %}` /
  `{% set texts = ... %}`) — lógica de estado do botão a preservar.
