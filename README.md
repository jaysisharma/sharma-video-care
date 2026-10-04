# Sharma Video Care — Antigravity Project Documentation

This repository is the product specification and implementation source of truth for Sharma Video Care.

## Confirmed stack
- Web: Next.js
- Mobile: Flutter
- Backend: Firebase
- Auth: Firebase Authentication
- Database: Cloud Firestore
- Image storage: Cloudinary (cloud: esmfahf0)
- Files & assets: Cloud Storage / Cloudinary
- Server logic: Cloud Functions
- Notifications: WhatsApp + email
- Payments: COD + bank transfer
- Delivery: courier partners

## Confirmed business model
- Repair/service: Janakpur initially.
- Product delivery: nationwide Nepal.
- Inspection: free.
- Visit: free.
- Repair quote: after diagnosis.
- External technician split: 90% Sharma Video Care / 10% technician, configurable in Admin.
- Warranty/returns: product/service-specific.
- Second-hand: Sharma Video Care only.
- Product sourcing: internal, no customer deposit initially.
- Chat: customer ↔ responsible team/technician/product support.

## Source of truth
1. Explicit confirmed decisions.
2. Business rules.
3. PRD.
4. Architecture.
5. Design system.

If a critical decision remains open, do not invent it.

## Theme
Use:
`packages/design-tokens/theme.json`

Web:
`apps/web/theme.css`

Flutter:
`apps/mobile/theme_tokens.dart`

All screens/components must consume these tokens.

## Legal note
The legal draft is an implementation starting point, not a substitute for legal review. The current draft is based on the Nepal Law Commission's published Electronic Commerce Act 2081, Consumer Protection Act 2075 and Privacy Act 2075, but final legal text should be reviewed for the actual business.
