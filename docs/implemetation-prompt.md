You are operating in IMPLEMENTATION MODE.

You are now allowed to write code.
But ONLY within the boundaries of the approved implementation plan.

Architecture Contract has higher priority than the plan.
If conflict exists, STOP and explain.

--------------------------------------------------
STEP 1 — Load Inputs
--------------------------------------------------
<feature-slug>: `correcao-bugs-interacao-carrinho-header`

Read:

1) docs/architecture-map.md
2) docs/plans/<feature-slug>.md

Extract:
- Applicable invariants
- Execution phases
- Non-modification areas

Do NOT restate the full contract.

--------------------------------------------------
STEP 2 — Pre-Implementation Validation
--------------------------------------------------

Before writing code:

- Confirm invariant compliance
- Confirm no scope expansion
- Confirm risk zones

If any ambiguity exists:
Stop and request clarification.

Identify at least 2 similar implementations in the codebase.

Analyze and extract:
- Structural pattern
- Naming pattern
- Layer interaction
- Styling conventions
- Error handling conventions

Summarize detected pattern under:

## Detected Existing Pattern

New implementation MUST follow this pattern strictly.
No deviations allowed.

--------------------------------------------------
STEP 3 — Execute by Phase
--------------------------------------------------

Implement strictly by phase order defined in the plan.

For each phase:

1. State which phase is being executed
2. List affected files
3. Apply minimal necessary changes
4. Do NOT modify unrelated files
5. Do NOT refactor outside scope

--------------------------------------------------
STEP 4 — Styling / Component Safety
--------------------------------------------------

If the feature modifies:

- Components
- CSS
- Tailwind classes
- Layout
- Images

You MUST:

- Preserve existing patterns
- Respect architectural layer boundaries
- Avoid introducing business logic in UI
- Avoid breaking shared components

--------------------------------------------------
STEP 5 — Final Compliance Report
--------------------------------------------------

After implementation, output:

# IMPLEMENTATION REPORT

## Modified Files
(list only modified/created files)

## Invariant Compliance Check
Explain how each invariant was respected.

## Scope Check
Confirm no out-of-scope changes were made.

## Risk Re-evaluation
LOW / MEDIUM / HIGH
Explain if anything changed.

--------------------------------------------------

STRICT RULES:

- No architectural redesign.
- No global refactor.
- No silent file modifications.
- No best-practice suggestions outside scope.
- No expanding feature.
- Follow the plan strictly.