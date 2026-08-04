# Spec-Driven Development

Este é o workflow de desenvolvimento deste repositório. Substitui o antigo
esquema `research-prompt.md` → `plan-prompt.md` → `implemetation-prompt.md`
(removido). `docs/architecture-map.md` continua sendo o contrato de
arquitetura — tem prioridade sobre qualquer spec em caso de conflito.

## Estrutura

```
docs/specs/<feature-slug>/
  plan.md              # plano geral da feature
  01-<nome-da-spec>.md # fatia implementável do plano
  02-<nome-da-spec>.md
  ...
```

- `<feature-slug>`: kebab-case, mesmo padrão já usado em `docs/plans/` e
  `docs/researches/` (histórico do workflow anterior, mantido como
  referência — não é mais onde novo trabalho é registrado).
- Cada spec é numerada na ordem em que deve ser implementada. Duas specs sem
  relação de dependência entre si podem compartilhar prefixo numérico se
  puderem ser feitas em qualquer ordem — mas o padrão é uma sequência linear.

## `plan.md`

Nasce de uma conversa/prompt de planejamento (não de uma skill automatizada):
descrever a feature, pesquisar o código existente, chegar a um plano em
camadas. Contém:

- Contexto e objetivo da feature.
- Domínios/arquivos afetados.
- Riscos e zonas de não-modificação.
- A lista de specs em que o plano foi quebrado (com uma frase por spec).

`plan.md` nunca é implementado diretamente — só orienta a criação das specs
numeradas.

## Anatomia de uma spec

```markdown
---
feature: <feature-slug>
spec: NN-<nome-da-spec>
status: pending   # pending | in-progress | done | blocked
depends_on: []     # outras specs (mesmo feature-slug) que precisam estar done antes
---

## Objetivo

1-2 frases: o que essa spec entrega, e só isso.

## Escopo

Lista explícita de arquivos/domínios que podem ser tocados. Qualquer
mudança fora dessa lista exige parar e perguntar ao usuário antes de prosseguir.

## Critérios de aceite

- [ ] Condição verificável 1
- [ ] Condição verificável 2

## Invariantes aplicáveis

Códigos de docs/architecture-map.md relevantes aqui (ex: A3, L2, F5).

## Referências de padrão

2+ implementações existentes no código que servem de modelo de estilo,
nomenclatura e estrutura para esta spec.
```

Specs devem ser pequenas o bastante para serem implementadas, validadas no
preview da Nuvemshop e fechadas numa única sessão.

## Uso

1. Planejamento: conversa com a IA descrevendo a feature (texto ou a partir
   de um design/Figma) → produz `docs/specs/<feature-slug>/plan.md` + specs
   numeradas.
2. Implementação: `/implement-spec docs/specs/<feature-slug>/NN-nome.md` —
   uma spec por vez. Ver `.claude/skills/implement-spec/SKILL.md`.
3. Quando todas as specs de uma feature estão `status: done`, a feature está
   pronta para a skill `/pr`.
