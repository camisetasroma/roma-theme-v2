You are operating in ARCHITECTURE DRIFT AUDIT MODE.

Your job is to audit the architectural contract against the real implementation
and eliminate weak governance.

--------------------------------------------------
STEP 1 — Load Contract
--------------------------------------------------

Read:
docs/architecture-map.md

--------------------------------------------------
STEP 2 — Compare Against Implementation
--------------------------------------------------

Systematically compare:

- Layer responsibilities vs actual folder usage
- Invariants vs real code behavior
- Dependency rules vs actual imports
- State management contract vs actual state usage
- Data flow contract vs actual API calls
- External library rules vs real integration

--------------------------------------------------
STEP 3 — Identify Problems
--------------------------------------------------

For each invariant:

Classify as:

- VALID (clearly enforced by implementation)
- WEAK (vague, non-measurable, ambiguous)
- DRIFTED (implementation violates it)
- REDUNDANT (adds no governance value)

For WEAK or DRIFTED invariants:

Explain:
- Why it is weak or violated
- What makes it non-enforceable

--------------------------------------------------
STEP 4 — Strengthen the Contract
--------------------------------------------------

Rewrite:

- Weak invariants → make them strict and measurable
- Drifted invariants → either strengthen OR formally relax (with justification)
- Remove redundant ones
- Add missing invariants if structural patterns exist but are not formalized

Rules must use:
MUST / MUST NOT / ONLY / NEVER / REQUIRED

No soft language.

--------------------------------------------------
STEP 5 — Generate Drift Report
--------------------------------------------------

Create:

docs/architecture-drift-reports/<timestamp>-drift-audit.md

Include:

# ARCHITECTURE DRIFT AUDIT

## Summary

## Invariant Classification Table

Invariant | Status | Severity | Action Taken

## Drift Details

## Strengthened Invariants

--------------------------------------------------
STEP 6 — Update Contract
--------------------------------------------------

Update:
docs/architecture-map.md

Apply the strengthened invariants directly in the document.

Do NOT rewrite unrelated sections.
Preserve structure.

--------------------------------------------------

STRICT RULES:

- No generic best practices.
- No architecture redesign.
- Only governance improvement.
- Be precise.
- Be deterministic.