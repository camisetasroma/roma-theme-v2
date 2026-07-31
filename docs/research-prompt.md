You are operating in FEATURE SCOPED ANALYSIS MODE.

You are NOT allowed to implement.
You are NOT allowed to generate code.
You are NOT allowed to propose refactors.

Architecture Contract has higher priority than the feature request.
If conflict exists, the contract wins.

--------------------------------------------------
STEP 1 — Load Contract
--------------------------------------------------

Read:
docs/architecture-map.md

Extract internally:
- ARCHITECTURE INVARIANTS (COMPACT)
- Domain rules relevant to this feature

Do NOT output the full contract.

--------------------------------------------------
STEP 2 — Feature Input (Portuguese Structured Spec)
--------------------------------------------------

The feature will be described in Portuguese using this structure:

# FEATURE REQUEST

## 1. Nome da Feature
Correção de Bugs: Interação carrinho e header.

## 2. O que faremos de novo
- Carrinho e header na home:
    Quando estivermos com o scroll no topo ao abrir o carrinho, ele deve ativar o header
    Quando estivermos em outra posição da tela, o header já estará ativo, então o carrinho deverá abrir e manter o header como está

- Carrinho e header nas outras páginas:
    Deve seguir as mesmas lógicas do header e carrinho na home, com a diferença que nas outras páginas o header no topo, meio que já está ativo.

## 3. Contexto Atual
Hoje o header está funcionando bem, porém algo na integração header e carrinho não funciona bem, anteriormente o claude delirou, e não estava entendendo todo o contexto entre os dois componentes

## 4. Objetivo
corrigir intereção header e carrinho

## 5. Considerações Técnicas
Respeitar as dinamicas atuais do header para que não tenhamos grandes alterações no header, de como ele se comporta e funciona.

## 6. Impacto Visual

## 7. Componentes Envolvidos

Header
Carrinho

## 8. CSS / Classes / Estrtura HTML

## 9. Assets / Imagens

## 10. Fora de Escopo

You MUST:

- Normalize the feature internally
- Remove ambiguity
- Identify architectural domains affected
- Identify invariant constraints
- Consider image descriptions if provided
- Consider CSS/class modifications as architectural surface area

If something is unclear:
- Explicitly list assumptions
- Do NOT invent behavior

--------------------------------------------------
STEP 3 — Generate Feature Slug
--------------------------------------------------

Create a kebab-case slug based on the feature name.

--------------------------------------------------
STEP 4 — Save Research
--------------------------------------------------

Create:

docs/researches/<feature-slug>.md

Write EXACTLY this structure:

# FEATURE SCOPED ANALYSIS

## 1. Feature Summary (Normalized)

## 2. Assumptions (if any)

## 3. Affected Architectural Domains

## 4. Applicable Invariants (Codes Only)

## 5. Invariant Impact Explanation

## 6. Risk Assessment (LOW / MEDIUM / HIGH)

## 7. Likely Impacted Areas (Scoped)

## 8. Visual / Component Surface Impact

## 9. Architectural Constraints Summary

--------------------------------------------------

STRICT RULES:

- No code.
- No implementation plan.
- No redesign suggestions.
- No repetition of full architecture contract.
- Keep analysis precise and scoped.
- Be deterministic.