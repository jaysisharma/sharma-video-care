# Security & Permissions

## Requirements
- Firebase Authentication.
- Server-side authorization.
- Role-based access.
- Firestore security rules.
- Storage security rules.
- App Check where applicable.
- Input validation.
- File type/size restrictions.
- Rate limiting/abuse protection for public endpoints.
- Audit logging.
- Least privilege.

## Critical isolation
Customer A must never read Customer B's service requests, orders, addresses or private chats.

Technicians must only access assigned jobs and the minimum customer information needed.

External technicians must not gain admin privileges.

Customers cannot directly modify:
- quote totals,
- payment verification,
- order fulfillment status,
- technician assignment,
- inventory,
- service diagnosis.

## Files
Uploaded images/videos/documents must be stored securely and accessed through authorized URLs/rules.
