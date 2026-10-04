# System Architecture

## Confirmed backend
Firebase.

Recommended Firebase components:
- Firebase Authentication.
- Cloud Firestore.
- Cloudinary (primary for image uploads and media hosting; cloud: esmfahf0).
- Cloud Storage (optional backup / document storage).
- Cloud Functions.
- Firebase Cloud Messaging.
- Firebase App Check where appropriate.
- Firebase Hosting if suitable for the web frontend.

Confirmed frontend: Next.js for the customer website and Flutter for the mobile application. Admin web dashboard should use the same Next.js web stack unless separately approved.

## Logical architecture

Customer Web / Customer Mobile
        |
        v
Firebase Auth
        |
        v
Application services / Cloud Functions / Server Actions
        |
        +--> Firestore
        +--> Cloudinary (Images) / Cloud Storage
        +--> Notifications
        +--> Audit logs

Admin Dashboard ---------^
Technician App ----------^

## Principles
- Business rules must not live only in the client.
- Validate permissions server-side.
- Use Firestore transactions/batched writes where consistency requires them.
- Store image assets in Cloudinary; store metadata and URLs in Firestore.
- Avoid exposing sensitive fields to clients.
- Use role-based custom claims or equivalent secure authorization.
- Maintain audit trails for important actions.
- Design collections for actual query patterns rather than relational assumptions.

## Suggested domain collections
users
roles
customers
technicians
serviceCategories
services
serviceRequests
inspections
jobs
quotes
quoteItems
products
productCategories
inventory
usedProducts
sourceRequests
carts
orders
orderItems
payments
addresses
conversations
messages
notifications
reviews
settings
auditLogs

Exact schema and denormalization strategy must be defined in 09-DATABASE-SCHEMA.md.


## Theme architecture
Use one central design-token source of truth. Web and Flutter theme layers consume the same semantic tokens. Never scatter raw brand colors through components.

Recommended structure:
- `packages/design-tokens/theme.json` — source of truth.
- `apps/web/src/theme/*` — Next.js/CSS variables and component theme.
- `apps/mobile/lib/theme/*` — Flutter ThemeData and semantic tokens.

Changing the source tokens must update the whole product consistently.
