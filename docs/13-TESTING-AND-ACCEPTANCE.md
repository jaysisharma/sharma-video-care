# Testing & Acceptance

## Test layers
- Unit tests.
- Service/business-rule tests.
- Firebase security rules tests.
- Cloud Function tests.
- Integration tests.
- Web end-to-end tests.
- Mobile end-to-end tests.
- Manual UX testing.

## Critical scenarios
1. Customer submits repair request.
2. Admin assigns internal technician.
3. Admin assigns external technician.
4. Technician performs inspection.
5. Technician submits diagnosis.
6. Admin sends quote.
7. Customer accepts quote.
8. Customer rejects quote.
9. Quote expires.
10. Additional work requires revised approval.
11. Customer buys an in-stock product.
12. Customer requests a sourced product.
13. Customer buys a used product.
14. Customer submits bank-transfer proof.
15. Admin verifies payment.
16. COD order flows to delivery.
17. Customer chats with support.
18. Customer chats with assigned technician.
19. Unauthorized user attempts to access another customer's data.
20. Technician attempts to access an unassigned job.
21. Product inventory reaches zero.
22. Concurrent orders attempt to consume the last unit.

## Definition of Done
A feature is complete only if:
- UI works.
- Backend works.
- Security rules work.
- Loading/error/empty states exist.
- Notifications are implemented where required.
- Tests pass.
- No unauthorized access exists.
- Documentation is updated.
