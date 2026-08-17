---
feature: pagina-de-produto
spec: 09-carrossel-relacionados
status: blocked
depends_on: ["01-fundacao-layout-e-preco"]
---

> **ADIADO — não faz parte da sequência ativa desta feature.** Por decisão
> do usuário, "Leve junto" vai ser desenhado como um componente
> reutilizável em outras partes do site (não só a PDP), então será tratado
> numa feature própria mais pra frente, não dentro do redesenho da PDP.
> `snipplets/product/product-related.tpl` continua como está hoje
> (Bootstrap/legado) até lá — nenhuma outra spec desta feature depende
> desta, e `10-cleanup-e-arquitetura` não audita este arquivo. Este
> documento fica aqui só como registro da investigação já feita
> (principalmente o risco do `desktopColumns` hardcoded, útil quando a
> feature de componente reutilizável for planejada). **Não rodar
> `/implement-spec` neste arquivo** até essa decisão ser revisitada.

## Objetivo

Reestilizar em Tailwind o carrossel "Leve junto" (produtos relacionados e
complementares) do Figma, reaproveitando o Swiper legado já existente e
específico da PDP — sem escrever JS novo.

## Descoberta que define o escopo

Diferente da galeria principal (spec 02) e do quickbuy (spec 04), o Swiper
das seções relacionadas/complementares (`.js-swiper-related`/
`.js-swiper-complementary`, inicializado em `static/js/store.js.tpl:692-
737`) **já é específico da PDP, já funciona e já tem breakpoints/loop
corretos** (`slidesPerView: {{ columns }}` mobile, `desktopColumns` a partir
de 767px). O componente de plataforma `products-section` (chamado em
`snipplets/product/product-related.tpl`) aceita um parâmetro
`section_classes` que já controla individualmente as classes de CADA parte
do DOM gerado (section, container, title, products_container,
slider_container, slider_wrapper, pagination, prev/next) — ou seja, dá para
reestilizar 100% em Tailwind só trocando esses valores, sem tocar em JS.
**Não introduzir um módulo custom aqui** — seria retrabalho desnecessário e
divergiria do Swiper que já está correto.

**Risco novo, confirmado no Figma node `131:1503` ("Desktop - 3")**: no
desktop, "Leve junto" **não é mais uma seção larga** — fica confinado aos
564px da coluna direita definida na spec 01, com cards do mesmo tamanho do
mobile (234px, ~2,3 visíveis por vez). O `desktopColumns` usado pelo
Swiper legado (`store.js.tpl:673`/`2429`) é **hardcoded como `3` ou `4`**
(a partir de `settings.grid_columns`, uma config sitewide, não específica
desta seção) e foi pensado para uma seção larga — não para uma coluna de
564px. Reaproveitar sem ajuste espremeria 3-4 cards nesse espaço, o que não
bate com o Figma. Como `store.js.tpl` não pode ser editado (F1/A4):

- [ ] Primeiro, testar no preview real como o Swiper legado se comporta
      quando o container pai é limitado a ~564px de largura (`slidesPerView`
      é geralmente calculado sobre a largura do container, então o
      resultado pode já ficar aceitável mesmo com `desktopColumns` alto —
      **não assumir que vai quebrar, verificar**).
- [ ] Se o resultado não bater com o Figma (cards menores que 234px ou
      número de cards visível muito diferente de ~2,3), tentar resolver só
      com CSS (ex.: forçar `.js-swiper-related .swiper-slide`/
      `.js-swiper-complementary .swiper-slide` para uma largura fixa em
      `lg:`, deixando o overflow/scroll do Swiper lidar com o resto).
- [ ] Se CSS não for suficiente, **parar e perguntar ao usuário antes de
      introduzir JS custom** para este carrossel especificamente no
      desktop — isso reverteria a decisão desta spec de não escrever JS
      novo, e é uma mudança de escopo grande o suficiente para não ser
      decidida sozinho durante a implementação.

## Escopo

- `snipplets/product/product-related.tpl` — reescrita dos valores de
  `section_class`, `container_class`, `title_class`,
  `products_container_class`, `slider_container_class`,
  `swiper_wrapper_class`, `slider_control_pagination_class`,
  `slider_control_class`, `slider_control_prev_class`,
  `slider_control_next_class` (hoje Bootstrap) para Tailwind, troca de
  `product_template_path: 'snipplets/grid/item.tpl'` para
  `'snipplets/grid/item-card.tpl'` (card já modernizado, com quickbuy), e
  troca de `control_prev`/`control_next` (hoje `include
  ('snipplets/svg/chevron-left.tpl'...)`/`chevron-right.tpl`) para ícones
  Lucide (`chevron-left`/`chevron-right` existem na biblioteca — A14/F5:
  não é permitido manter SVG snipplet quando o ícone existe no Lucide).
- `__src/css/app.css` — nova regra CSS (não Tailwind puro) para aproximar a
  paginação do Swiper (`.swiper-pagination-bullet`/
  `.swiper-pagination-bullet-active` dentro de
  `.js-swiper-related-pagination`/`.js-swiper-complementary-pagination`) da
  forma de "semente" usada em `product-carousel.js`, via `background`/
  `clip-path`/máscara — sem JS, sem tocar `store.js.tpl` (o
  `renderBullet` customizado exigiria isso, por isso está fora de escopo).
- Proibido nesta spec: `static/js/store.js.tpl`, criar qualquer módulo em
  `__src/js/modules/product/`, `snipplets/grid/item.tpl` (o card antigo
  continua existindo para outros usos, só deixa de ser referenciado aqui).

## Critérios de aceite

- [ ] Título da seção ("Leve junto" ou o texto de
      `settings.products_related_title`/`products_complementary_title`) no
      padrão tipográfico Larken ExtraBold do Figma.
- [ ] Cards usam `snipplets/grid/item-card.tpl` (mesmo visual/quickbuy do
      resto do site) dentro do slider.
- [ ] Setas prev/next em Lucide (`chevron-left`/`chevron-right`), não mais
      SVG snipplet.
- [ ] Paginação visualmente aproximada da "seed" usada em
      `product-carousel.js`, via CSS apenas.
- [ ] Nenhuma classe `js-swiper-related*`/`js-swiper-complementary*`
      renomeada ou removida (são o contrato com `store.js.tpl:692-737`).
- [ ] Slider funciona (arrasta, seta, paginação clicável) idêntico ao
      comportamento atual, só com visual novo.
- [ ] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A8/F4 — sem cor hardcoded na paginação (usar tokens/`var(--accent-color)`).
- A14/F5 — trocar SVG snipplet de seta por Lucide.
- F1/A4 — `static/js/store.js.tpl` não é editado.
- R3 — classes `js-swiper-related*`/`js-swiper-complementary*` preservadas.

## Referências de padrão

- **Figma node `131:1503`** ("Desktop - 3") — "Leve junto" confinado à
  coluna de 564px no desktop, cards de 234px.
- `snipplets/grid/item-card.tpl` — card a reutilizar.
- `__src/js/modules/home/product-carousel.js` — referência visual da
  paginação "seed" (para aproximar via CSS, não para copiar a lógica JS).
- `templates/category.tpl` — uso de ícones Lucide em vez de SVG snipplet
  (`list-filter`, `chevron-down`, etc.) como precedente de migração A14.
