---
name: implement-spec
description: Implementa UMA spec de docs/specs/<feature-slug>/NN-nome.md — lê a spec e o plan.md da feature, valida contra docs/architecture-map.md, localiza padrões existentes similares, implementa estritamente dentro do escopo declarado, roda `npm run build` se `__src/` mudou, confere os critérios de aceite, atualiza o status da spec e termina com relatório de conformidade. Não commita, não builda especulativamente fora de escopo, não avança para outra spec. Use quando o usuário pedir para "implementar a spec X", "rodar a spec NN", ou passar um caminho dentro de docs/specs/.
---

# /implement-spec

Implementa exatamente uma spec do workflow spec-driven descrito em
`docs/specs/README.md`. Não é uma skill de planejamento — assume que
`docs/specs/<feature-slug>/plan.md` e a spec numerada já existem e foram
aprovados pelo usuário. Não é a skill `/pr` — não commita, não faz push, não
abre PR; para no fim da implementação.

**O Architecture Contract (`docs/architecture-map.md`) tem prioridade sobre
a spec.** Se a spec pedir algo que viola um invariante, pare e explique o
conflito em vez de implementar.

## Entrada

Caminho para uma spec: `docs/specs/<feature-slug>/NN-nome.md`. Se o usuário
não passar um caminho explícito, pergunte qual spec — nunca adivinhe a partir
do contexto da conversa.

## Fase 0 — Carregar entrada

Leia, nesta ordem:

1. A spec alvo (`docs/specs/<feature-slug>/NN-nome.md`) — extraia
   `status`, `depends_on`, Objetivo, Escopo, Critérios de aceite, Invariantes
   aplicáveis, Referências de padrão.
2. `docs/specs/<feature-slug>/plan.md` — contexto da feature como um todo,
   pra entender por que essa spec existe.
3. As seções de `docs/architecture-map.md` referenciadas em "Invariantes
   aplicáveis" (não releia o contrato inteiro se a spec já apontou os
   códigos relevantes).

Verificações antes de prosseguir:

- Se `status` já for `done`, avise o usuário e pergunte se é reimplementação
  intencional antes de continuar.
- Se `depends_on` lista specs que não estão `status: done`, pare e reporte
  quais — não implemente fora de ordem sem confirmação explícita.
- Se a spec não tiver seção "Escopo" ou "Critérios de aceite" preenchida,
  pare — spec incompleta não deve ser implementada às cegas.

## Fase 1 — Validação pré-implementação

Antes de escrever qualquer código:

- Confirme que o escopo declarado na spec não conflita com nenhum invariante
  de `docs/architecture-map.md`. Se conflitar, pare e explique — não
  implemente uma versão "ajustada" silenciosamente.
- Localize **2+ implementações existentes** no código que sirvam de modelo
  (a spec pode já apontar essas referências em "Referências de padrão"; se
  não apontar, procure você mesmo antes de continuar). Extraia dessas
  referências: padrão estrutural, nomenclatura, forma de integração entre
  camadas (ex: módulo JS ↔ classe `js-*` ↔ template), convenções de estilo.
- Se algo na spec for ambíguo (arquivo alvo não existe, critério de aceite
  não é verificável, escopo contradiz o plan.md), pare e peça esclarecimento
  ao usuário em vez de assumir.

Reporte brevemente o padrão detectado antes de seguir pra Fase 2.

## Fase 2 — Implementação

- Implemente **apenas** o que está no "Escopo" da spec. Qualquer necessidade
  de tocar um arquivo fora dessa lista exige parar e perguntar antes de
  editar.
- Mudanças mínimas necessárias para atender aos critérios de aceite — sem
  refatorar código não relacionado, sem "aproveitar e melhorar" outras
  partes do arquivo.
- Siga o padrão detectado na Fase 1. Divergência do padrão existente exige
  justificativa explícita ao usuário, não é uma decisão silenciosa.
- Depois de inserir HTML com `<i data-lucide="...">`, lembre de chamar
  `lucide.createIcons()` (regra geral do repo, não repita o contrato
  inteiro).

## Fase 3 — Build (se `__src/` mudou)

Se algum arquivo em `__src/` foi criado/modificado nesta spec:

- Rode **`npm run build`** (nunca `node esbuild.config.mjs` isolado — pula o
  passo de cache-busting que sincroniza `esbuild.config.mjs` e
  `layouts/layout.tpl` com o novo `gaius-v{epoch}.js`).
- Confirme que os artefatos gerados (novo `.js`, `.js` antigo removido,
  `esbuild.config.mjs`, `layouts/layout.tpl`, `static/css/app.tpl` se CSS
  mudou) aparecem no `git status` — eles fazem parte desta spec e devem ser
  commitados juntos quando o usuário rodar `/pr` depois.

Se `__src/` não mudou, pule esta fase.

## Fase 4 — Conferência dos critérios de aceite

Percorra cada item de "Critérios de aceite" da spec e confirme, um a um, se
foi atendido. Não marque um critério como atendido sem justificar como foi
verificado (leitura de código, build passou, comportamento esperado no
template).

Este repo não tem servidor de dev local nem testes automatizados — validação
de UI é sempre manual no preview do admin Nuvemshop. Se algum critério só
pode ser confirmado visualmente, deixe isso explícito no relatório final em
vez de assumir que passou.

## Fase 5 — Atualizar status da spec

Edite o front-matter da spec implementada:

- `status: done` se todos os critérios de aceite foram atendidos.
- `status: blocked` se parou por ambiguidade, conflito de invariante, ou
  dependência não resolvida — inclua o motivo como comentário logo abaixo do
  front-matter.

Nunca marque `done` com critérios pendentes.

## Fase 6 — Relatório final de conformidade

Termine a resposta com:

```
# RELATÓRIO DE IMPLEMENTAÇÃO — <feature-slug>/NN-nome

## Arquivos modificados/criados
(lista)

## Conformidade de invariantes
Como cada invariante listado em "Invariantes aplicáveis" foi respeitado.

## Critérios de aceite
- [x]/[ ] cada item, com nota de como foi verificado

## Escopo
Confirmação de que nada fora do escopo declarado foi tocado (ou, se algo
precisou sair do escopo, o que e por quê — deve já ter sido confirmado com
o usuário na Fase 2, não uma surpresa aqui).

## Pendente de validação manual
O que só pode ser confirmado no preview da Nuvemshop.
```

## Regras

- Nunca implemente mais de uma spec numa única invocação — se o usuário
  pedir "implementa todas", implemente a primeira pendente, reporte, e
  pergunte se segue para a próxima.
- Nunca commite, dê push ou abra PR — isso é `/pr`, depois de o usuário
  validar no preview.
- Nunca expanda escopo silenciosamente, mesmo que a mudança pareça pequena
  ou óbvia.
- Se o contrato de arquitetura e a spec conflitarem, o contrato vence —
  pare e explique em vez de escolher por conta própria.
- Sem sugestões de best-practice fora do escopo da spec — isso é assunto
  para uma spec futura, não para esta implementação.
