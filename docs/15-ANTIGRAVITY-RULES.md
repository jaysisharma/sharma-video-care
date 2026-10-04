# Antigravity Development Rules

## Primary instruction
Build Sharma Video Care as one integrated product. Do not implement isolated mock screens that are disconnected from the actual data and workflows.

## Before coding
1. Read all docs in /docs.
2. Identify dependencies.
3. Check existing code before creating new architecture.
4. Never invent unresolved business rules.
5. Record assumptions in the implementation plan.

## Architecture
- Follow the confirmed Firebase architecture.
- Keep business logic server-side where security/consistency matters.
- Do not duplicate domain logic across web/mobile.
- Prefer shared models/types where the chosen stack supports them.

## Database
- Do not create duplicate entities.
- Do not rename production fields casually.
- Use migrations/data scripts only when explicitly required and tested.
- Protect production data.

## UI
- Follow the design system.
- Avoid excessive icons.
- Build responsive layouts.
- Every screen needs loading, empty, success and error states where applicable.

## Security
- Never trust client-supplied role/price/payment/status values.
- Enforce authorization in Firestore rules and/or server functions.
- Validate all uploads and inputs.

## Workflow integrity
Do not mark a feature complete until the entire workflow works end to end.

## Changes
For every significant change:
- Explain what changed.
- List affected files.
- List database/security implications.
- List tests performed.
- Update relevant docs.

## Uncertainty
If a missing decision materially affects architecture, security, money, legal terms or customer experience:
STOP and ask for the decision rather than guessing.

## Product truthfulness
Never expose false stock/availability claims. Sourced-on-request inventory must be represented accurately.

## Completion
At the end of each implementation phase:
- Run tests.
- Check security.
- Check affected flows.
- Update IMPLEMENTATION-PLAN.md.


## Theme rule
All UI must consume the centralized theme tokens. Do not hard-code brand colors in individual screens/components. If a brand color changes, update the source token file and propagate the change.

## Business configuration rule
Admin-configurable commercial values must be stored as configuration/settings, not constants in client code. This includes technician commission percentage, warranty/return templates, service availability, delivery charges and similar operational settings.
