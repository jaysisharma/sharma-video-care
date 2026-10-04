# Sharma Video Care — Product Requirements Document

## A. Customer website
### Home
- Hero with clear value proposition.
- Repair/service CTA.
- Shop CTA.
- Used products CTA.
- Custom request CTA.
- Service categories.
- Featured products.
- Featured used products.
- How it works.
- Trust/reviews.
- Contact/support.

### Services
- Browse categories.
- Service detail page.
- Problem selection.
- Description.
- Photo/video upload.
- Location.
- Preferred date/time.
- Inspection requirement.
- Request submission.
- Request status.

### Custom service
Customer can describe any job not represented by a predefined service, e.g. TV wall mounting, installation, setup, assembly or other technical work.

### Shop
- Search.
- Filters.
- Category.
- Product detail.
- Availability.
- Quantity.
- Cart.
- Checkout.
- COD/bank transfer.
- Order tracking.

### Source on request
Customer can request a product that is not currently listed.
Fields:
- Product name.
- Brand/model if known.
- Quantity.
- Budget (optional).
- Notes.
- Reference image/link (optional).
- Delivery location.
Admin can source and send a quotation.

### Used products
Only Sharma Video Care can create used-product listings.
Product detail must disclose condition, known defects, testing/inspection information and applicable warranty/return terms.

### Account
- Profile.
- Addresses.
- Orders.
- Service requests.
- Quotations.
- Source requests.
- Chats.
- Notifications.

## B. Repair/service workflow
1. Customer selects service.
2. Customer describes issue and uploads evidence.
3. Admin reviews request.
4. Inspection is scheduled/assigned when required.
5. Technician inspects/diagnoses.
6. Technician records diagnosis.
7. Admin/authorized staff issues quotation.
8. Customer accepts/rejects.
9. If accepted, work proceeds.
10. Parts/labour are recorded.
11. Job is completed.
12. Customer receives completion record and review request.

Default wording where diagnosis is required:
**Inspection required — final price after diagnosis.**

Quotes must support:
- Labour.
- Parts.
- Inspection fee, if applicable.
- Travel/visit fee, if applicable.
- Discounts.
- Taxes/other charges if later enabled.
- Total.
- Valid-until date.
- Notes.
- Customer acceptance/rejection.

## C. Technician
- Assigned jobs.
- Job details.
- Customer contact through controlled chat.
- Navigation/address.
- Inspection checklist.
- Diagnosis.
- Photos.
- Parts used.
- Labour notes.
- Status updates.
- Completion proof.
- Customer signature/confirmation if later enabled.

External technicians must have restricted permissions and only access jobs assigned to them.

## D. Orders
Statuses should be configurable but initially include:
PENDING_PAYMENT, PAYMENT_SUBMITTED, CONFIRMED, PROCESSING, READY_TO_DISPATCH, DISPATCHED, DELIVERED, CANCELLED, RETURN_REQUESTED, RETURNED, REFUNDED.

## E. Service statuses
REQUESTED, UNDER_REVIEW, INSPECTION_SCHEDULED, INSPECTION_IN_PROGRESS, QUOTE_PENDING, QUOTE_SENT, CUSTOMER_APPROVED, IN_PROGRESS, WAITING_FOR_PARTS, COMPLETED, CANCELLED, CLOSED.

## F. Chat
Chat contexts:
- Customer ↔ Support.
- Customer ↔ Assigned Technician.
- Customer ↔ Product Seller/support.

Features:
- Text.
- Images.
- Video/file attachments where safe.
- Read/unread state.
- Conversation status.
- Related order/service/request.
- Admin moderation/access.
- Notifications.

## G. Admin
- Dashboard.
- Customers.
- Technicians.
- Services.
- Service requests.
- Inspections.
- Quotations.
- Products.
- Inventory.
- Used products.
- Source requests.
- Orders.
- Payments.
- Delivery.
- Chats.
- Reviews.
- Notifications.
- Reports.
- Settings.
- Audit log.

## H. Acceptance principle
A feature is not complete when its screen exists. It is complete only when its end-to-end workflow, permissions, backend data, error handling, notifications and acceptance criteria work.


## I. Confirmed commercial rules
- Inspection and technician visit are free initially.
- Final repair quotation is prepared after diagnosis.
- Warranty and returns are configurable by product/service and must be visible to the customer before purchase/approval.
- External technician payout is initially 10% of the configured technician-eligible amount; Sharma Video Care retains 90%. The percentage must be editable by Admin without code changes.
- Product sourcing has no customer deposit initially.
- Courier partner is used for nationwide product delivery.
- Notifications use WhatsApp and email only initially.
