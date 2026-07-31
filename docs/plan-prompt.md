You are operating in IMPLEMENTATION PLANNING MODE.

You are NOT allowed to generate code.
You are NOT allowed to refactor unrelated areas.
You are NOT allowed to expand scope.

Your task is to generate a deterministic implementation plan
based strictly on the approved research file.

Architecture Contract has higher priority than the feature.
If conflict exists, the contract wins.

--------------------------------------------------
STEP 1 — Load Inputs
--------------------------------------------------
<feature-slug>: `correcao-bugs-interacao-carrinho-header`

Read:

1) docs/architecture-map.md
2) docs/researches/<feature-slug>.md

Extract internally:
- Applicable invariant codes
- Affected domains
- Architectural constraints summary

Do NOT output the full contract.

--------------------------------------------------
STEP 2 — Pre-Validation
--------------------------------------------------

Before creating the plan:

- Reconfirm invariant applicability
- Identify any invariant tension
- Confirm risk level (LOW / MEDIUM / HIGH)

If architectural violation would be required,
STOP and explain instead of planning.

--------------------------------------------------
STEP 3 — Generate Implementation Plan
--------------------------------------------------

Generate a structured plan divided by layer:

1. Data / Services Layer
2. State / Hooks Layer
3. UI / Components Layer
4. Styling Layer (if applicable)
5. Assets Integration (if applicable)

For each layer specify:

- What will be created
- What will be modified
- Why it is necessary
- Which invariant constrains it

--------------------------------------------------
STEP 4 — Dependency Ordering
--------------------------------------------------

Define strict execution order:

Phase 1:
Phase 2:
Phase 3:

Each phase must be logically incremental and testable.

--------------------------------------------------
STEP 5 — Risk Controls
--------------------------------------------------

List:

- Edge cases to validate
- Regression risk zones
- Areas that must NOT be modified

--------------------------------------------------
STEP 6 — Save Plan
--------------------------------------------------

Use the SAME <feature-slug> used in the research file.

Create:

docs/plans/<feature-slug>.md

Write EXACTLY this structure:

# IMPLEMENTATION PLAN

## 1. Architectural Validation

### Applicable Invariants
(list codes only)

### Invariant Tension Check

### Risk Level

---

## 2. Layered Implementation Strategy

### 2.1 Data / Services

### 2.2 State / Hooks

### 2.3 UI / Components

### 2.4 Styling

### 2.5 Assets

---

## 3. Execution Phases

Phase 1:
Phase 2:
Phase 3:

---

## 4. Risk Controls

### Edge Cases
### Regression Zones
### Strict Non-Modification Areas

--------------------------------------------------

STRICT RULES:

- No code.
- No pseudo-code.
- No refactor proposals outside scope.
- No architectural redesign.
- Must reference invariant codes where relevant.
- Must be deterministic and testable.