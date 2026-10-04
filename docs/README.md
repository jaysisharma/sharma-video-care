# Sharma Video Care — Antigravity Project Documentation

This documentation defines the intended product, business rules, architecture and implementation standards for Sharma Video Care.

## Confirmed decisions
- Users: Customer + Admin + Technician.
- Repair area: Janakpur initially.
- Product delivery: nationwide Nepal.
- Payments: COD + bank transfer.
- Technicians: internal + external.
- Customer platform: website first; mobile apps in scope.
- Second-hand: only Sharma Video Care sells used products.
- Backend: Firebase.
- Chat: Customer ↔ Support + Technician + Product seller.
- Image storage: Cloudinary for image uploads and media.

## How Antigravity should use this repository
1. Read README.md.
2. Read all files under docs/.
3. Resolve the critical decisions listed in the open-decisions document.
4. Build according to the PRD, business rules and architecture.
5. Never guess on critical unresolved decisions.
6. Keep IMPLEMENTATION-PLAN.md current.

## Critical source of truth
When documents conflict:
1. Explicitly confirmed user decisions.
2. Business rules.
3. PRD.
4. Architecture.
5. UI/design details.

If a conflict cannot be resolved, ask before implementing.
