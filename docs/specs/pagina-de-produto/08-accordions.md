---
feature: pagina-de-produto
spec: 08-accordions
status: done
depends_on: ["01-fundacao-layout-e-preco"]
---

## Objetivo

Implementar as seções em accordion "Descrição" (aberta por padrão) e
"Tabela de Medidas" (fechada, conteúdo reaproveitado de
`settings.size_guide_url`) do Figma, com um módulo JS genérico de
abrir/fechar.

**Nota de layout desktop**: confirmado no Figma node `131:1503` ("Desktop -
3") que os dois accordions ficam dentro da mesma coluna direita de 564px
da spec 01 (não viram uma seção larga no desktop) — a estrutura interna do
componente não muda entre breakpoints, só a largura do container pai
(já resolvida pela spec 01). Nenhuma mudança adicional necessária aqui além
de não assumir `w-full` de página inteira.

## Escopo

- Novo: `snipplets/product/product-accordions.tpl`.
- Novo: `__src/js/modules/product/product-accordion.js`.
- `templates/product.tpl` — inclui o novo snipplet no lugar do bloco atual
  de descrição (`{% if product.description is not empty %}...{% endif %}`
  em `templates/product.tpl`, que é removido/substituído).
- `__src/js/index.js` — novo import + atualização da contagem A3.
- Proibido nesta spec: qualquer settings novo em `config/settings.txt` — a
  fonte da Tabela de Medidas é exclusivamente a página apontada por
  `settings.size_guide_url` (setting já existente).

## Critérios de aceite

- [ ] "Descrição": título "Descrição" + ícone (minus quando aberto, plus
      quando fechado) + `product.description`, iniciando **aberta** por
      padrão (`data-state="open"` no item), conforme Figma. Some se
      `product.description` estiver vazio (mesma condicional de hoje).
- [ ] "Tabela de Medidas": título + ícone, iniciando **fechada**. Conteúdo
      é o `page.content` da página resolvida por handle a partir de
      `settings.size_guide_url` — reaproveitar exatamente a mesma lógica de
      resolução já usada hoje em `snipplets/product/product-variants.tpl`
      (busca em `pages` pelo handle extraído da URL configurada). Accordion
      inteiro não renderiza se `settings.size_guide_url` estiver vazio ou
      não corresponder a nenhuma página existente — nunca mostrar um
      accordion vazio.
- [ ] `product-accordion.js`: genérico (funciona para N itens, não hardcoded
      para exatamente 2), guard `if (!element) return;` (A2), cada item
      alterna `data-state="open"|"closed"` (padrão A9) e troca o ícone
      Lucide `minus`/`plus` correspondente, chamando
      `lucide.createIcons()` depois da troca (A6).
- [ ] O link "Tabela de Medidas" criado na spec 04 (ao lado do seletor de
      tamanho) aponta/rola para este accordion e o abre — implementar esse
      lado da integração aqui (a spec 04 só deixou o link preparado).
- [ ] `npm run build` executado sem erros.

## Invariantes aplicáveis

- A1/A2/A3/F6 — módulo novo no contexto `product/`.
- A9 — `data-state="open"|"closed"` por item.
- A6/L4 — `lucide.createIcons()` após troca de ícone.
- A10 — novo snipplet em `snipplets/product/`.
- T1/T5 — nenhum conteúdo novo inventado; tudo vem de
  `product.description`/`page.content`/`settings.size_guide_url` já
  existentes.

## Referências de padrão

- `__src/js/modules/system/menu.js` (accordion do menu mobile,
  `js-menu-accordion-toggle`/`js-menu-accordion-content`) — padrão de
  toggle com `aria-expanded`/`hidden` a adaptar (não importar, é um domínio
  diferente — F9 — mas o padrão de interação é o mesmo).
- `snipplets/product/product-variants.tpl` (versão atual, antes da spec 04)
  — lógica de resolução de página por `settings.size_guide_url` a
  reaproveitar.
