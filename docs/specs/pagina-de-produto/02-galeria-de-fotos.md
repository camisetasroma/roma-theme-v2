---
feature: pagina-de-produto
spec: 02-galeria-de-fotos
status: done
depends_on: ["01-fundacao-layout-e-preco"]
---

## Objetivo

Reescrever a galeria de fotos da PDP (`snipplets/product/product-image.tpl`)
em Tailwind, com badges e paginação no padrão visual do Figma, substituindo
o Swiper legado por um novo módulo custom `__src/js/modules/product/
product-gallery.js` — necessário para que as specs 03 (zoom fullscreen) e 04
(troca de imagem por variante) consigam controlar a galeria via `window.*`.

**Importante — a galeria muda de paradigma no desktop, não é só uma
adaptação de largura.** Confirmado no Figma node `131:1503` ("Desktop -
3"): abaixo de `lg:`, a galeria continua sendo um carrossel horizontal (1
imagem por vez, paginação seed + setas, como já especificado abaixo). A
partir de `lg:`, ela vira uma **grade estática de 2 colunas com TODAS as
fotos do produto visíveis ao mesmo tempo** (sem swiper, sem paginação, sem
setas), dentro de um container com `overflow-y-auto` (rola verticalmente se
houver mais fotos do que cabem na altura visível). São dois markups
diferentes por breakpoint, não o mesmo componente redimensionado.

## Escopo

- `snipplets/product/product-image.tpl` — reescrita completa do slider de
  fotos (mantém o `{% include 'snipplets/product/product-video.tpl' %}`
  existente dentro do slider, sem alterar `product-video.tpl`).
- Novo: `__src/js/modules/product/product-gallery.js`.
- `__src/js/index.js` — novo import (comentário de contexto `//Product`,
  primeiro módulo desse novo contexto) + atualização da contagem de exports
  (invariante A3).
- `__src/css/app.css` — nova seção "PRODUCT PAGE STYLES" só se algo não for
  expressável em utilitário Tailwind puro (ex.: scroll-snap).
- Proibido nesta spec: `product-video.tpl`, `snipplets/video-item.tpl`
  (o slide de vídeo dentro da galeria continua como está — inclusive seu
  `data-fancybox`, que só é tratado na spec 03), qualquer arquivo de
  variantes/quantidade/CTA.

## Critérios de aceite

- [x] O container do slider usa um nome de classe **novo**, nunca
      `.js-swiper-product` / `.js-swiper-product-pagination` /
      `.js-swiper-product-next` / `.js-swiper-product-prev` (ex.:
      `.js-product-gallery`, `.js-product-gallery-pagination`, etc.) — essas
      classes legadas são lidas por `createSwiper('.js-swiper-product', ...)`
      em `static/js/store.js.tpl:1603-1644`; reaproveitá-las criaria um
      segundo `Swiper` concorrente no mesmo elemento.
- [x] Validado no preview real da Nuvemshop: `store.js.tpl` não lança erro ao
      rodar `new Swiper('.js-swiper-product', ...)` contra um seletor vazio.
- [x] `product-gallery.js` segue o padrão de `__src/js/modules/home/
      product-carousel.js`: guarda `if (!element) return;` (A2), usa
      `window.Swiper` global (nunca import npm — L3/F8), paginação em
      "seeds" (reaproveitar a mesma técnica de SVG usada em
      `product-carousel.js`, mas sem hardcode de cor — usar
      `getComputedStyle` como lá, corrigindo para não repetir o bug
      conhecido do fallback `#410911`/`#C4C4C0` documentado em A8/KNOWN
      BUGS), setas prev/next.
- [x] Badges de produto (ex. "Baggy", "12oz") renderizados sobre a primeira
      imagem, no mesmo padrão visual de badge de
      `snipplets/grid/item-card.tpl` (`[background:rgba(0,0,0,0.05)]`,
      `text-[10px] font-semibold rounded`).
- [x] O módulo expõe `window.setProductGalleryImage(imagePosition)` (nome
      final a critério da implementação, mas documentado em A5/S2 no final
      da feature — spec 10) que move o Swiper para o slide cuja
      `data-image-position` bate com o argumento — usado pela spec 04.
      Também expõe o necessário para a spec 03 saber qual é o slide ativo
      no momento (ex.: `data-active-position` sincronizado no container, ou
      função equivalente) sem que a spec 03 precise importar este módulo
      (F9 — só via DOM/`window.*`).
- [x] Lazy-load das imagens mantido (usar o mesmo padrão `data-src`/
      `data-srcset`/`lazyload` já usado no projeto, já que `lazysizes` é
      vendorizado e genérico, não específico do Swiper legado).
- [x] A partir de `lg:` (1024px), o markup do carrossel fica `lg:hidden` e
      um markup irmão (`hidden lg:grid lg:grid-cols-2 lg:gap-0`, largura
      total 876px conforme a coluna definida na spec 01) mostra **todas**
      as fotos do produto lado a lado/empilhadas, sem paginação/setas,
      com `overflow-y-auto` no container. `product-gallery.js` só precisa
      inicializar o Swiper para o markup do carrossel — não tentar rodar
      Swiper sobre a grade desktop (ela não é um slider). Badges aparecem
      só sobre a primeira foto em ambos os layouts.
- [x] **Decidido nesta implementação**: o clique em qualquer foto — mobile
      carrossel ou grade desktop — mantém `data-fancybox="product-gallery"`
      (mesmo atributo/trigger legado usado nos dois layouts), então o
      `Fancybox.bind('[data-fancybox="product-gallery"]', ...)` já ativo em
      `store.js.tpl` continua abrindo o zoom em ambos, até a spec 03
      substituir por um modal fullscreen custom.
- [x] `lucide.createIcons()` chamado após qualquer HTML dinâmico com
      `data-lucide` (A6), se houver ícones Lucide na paginação/setas em vez
      de SVG inline. — Não aplicável: as setas usam `<i data-lucide>`
      estático renderizado no server (coberto pelo `lucide.createIcons()`
      global do `layout.tpl`); a paginação em seeds é SVG inline via JS, sem
      `data-lucide`.
- [x] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A1/A2/A3/F6 — novo contexto `product/`, módulo com guard DOM, export
  nomeado importado em `index.js`.
- A8/F4 — sem cores hardcoded na paginação (corrigir, não repetir, o padrão
  problemático de `product-carousel.js` listado em A8/KNOWN BUGS).
- A12/L3/F8 — Swiper só via `window.Swiper` global.
- A6/L4 — `lucide.createIcons()` após innerHTML dinâmico.
- F9/R1 — sem import entre módulos irmãos; comunicação só via `window.*`.
- A10 — sem novo snipplet fora de `snipplets/product/`.

## Referências de padrão

- **Figma node `131:1503`** ("Desktop - 3") — estrutura real da grade de 2
  colunas no desktop (container `producPhtotosSliderContainer`, 876px,
  células de 438px).
- `__src/js/modules/home/product-carousel.js` — Swiper global, paginação
  seed em SVG, setas prev/next, guard DOM, breakpoints responsivos.
- `snipplets/grid/item-card.tpl` — padrão visual de badge.
- `docs/architecture-map.md` seção A8/KNOWN BUGS — cores hardcoded a NÃO
  repetir na nova paginação.
