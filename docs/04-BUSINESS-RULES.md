# Business Rules

## 1. Inspection and visit
- Inspection fee: **Free** initially.
- Technician visit/visit fee: **Free** initially.
- Final repair quotation is produced after diagnosis.
- The customer should not see an unverified fixed repair price before diagnosis.
- Customer-facing wording:
  **Inspection required — final price after diagnosis.**

## 2. Repair quotation
A quotation is based on the diagnosis and can include:
- Labour.
- Parts.
- Other explicitly disclosed charges.
- Discount.
- Total.
- Notes.
- Validity.
- Warranty applicable to the work/parts.

Quote statuses:
DRAFT, SENT, ACCEPTED, REJECTED, EXPIRED, CANCELLED, SUPERSEDED.

Any material additional work discovered after approval requires a revised quote/customer approval according to the configured rule.

## 3. Technician payout
Initial external technician split:
- Sharma Video Care: **90%**
- External technician: **10%**

The split must be an Admin-configurable setting. The system must store the percentage used at the time of a completed job so historical payouts do not change when the default percentage is later edited.

The calculation basis (for example, labour only vs total service amount) must be confirmed before production. Until confirmed, do not hard-code a payout basis.

## 4. Service area
- Repair/service operations: Janakpur initially.
- Product delivery: nationwide Nepal via courier partners.
- Service-area rules must be configurable for future expansion.

## 5. Products and sourcing
Internal availability:
- IN_STOCK
- SOURCE_ON_REQUEST
- SPECIAL_ORDER
- OUT_OF_STOCK

Customer-facing availability must be truthful.

No customer deposit is required for sourcing initially. Internal sourcing/procurement is handled by Sharma Video Care.

## 6. Second-hand products
Only Sharma Video Care can list/sell used products.

Every used listing should capture:
- Condition grade.
- Detailed condition description.
- Known defects.
- Functional test status.
- Test notes.
- Included accessories.
- Warranty, if any.
- Return eligibility.
- Photos.
- Serial/IMEI information where appropriate and legally permissible.

## 7. Warranty and returns
Warranty and return rules vary by product and service.

Therefore:
- Do not use one global return/warranty promise.
- Every product/service may have configurable warranty/return terms.
- Terms must be displayed before checkout or service approval.
- Admin must be able to configure eligibility, duration and notes.
- The legal/policy baseline must be reviewed before production launch.

For products with a no-return rule, the product page must clearly display the applicable restriction before purchase, subject to applicable law.

## 8. Payments
Initial methods:
- COD.
- Bank transfer.

Bank-transfer orders remain pending until manually verified.

Payment record:
- Amount.
- Reference.
- Proof.
- Status.
- Verified by.
- Verified at.

## 9. Delivery
- Nationwide product delivery is handled through courier partners.
- Courier assignment, tracking reference and delivery status must be stored.
- Exact delivery charges/rules are Admin-configurable.

## 10. Chat
A customer can chat with the team responsible for the query:
- Support/Admin.
- Assigned Technician.
- Product Seller/Product Support.

Conversation must be linked to the relevant service request, order, product enquiry or sourcing request.

## 11. Notifications
Initial channels:
- WhatsApp.
- Email.
- No SMS.

The exact WhatsApp provider/API and email provider are deployment decisions. Notification templates must be centralized.

## 12. Reviews
Reviews are tied to completed services/orders and duplicate reviews should be prevented.

## 13. Auditability
Log:
- Quote creation/changes.
- Payment verification.
- Technician assignment.
- Technician payout configuration used.
- Order status changes.
- Product/stock/price changes.
- Used-product changes.
- Warranty/return rule changes.
- Admin actions affecting customer money or service state.
