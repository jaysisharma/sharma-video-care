# Remaining Critical Decisions

Most product decisions are now confirmed.

## 1. External technician commission basis
Confirmed split: Sharma Video Care 90% / external technician 10%.
Still needed: what amount is split?
- Labour only?
- Labour + parts?
- Entire approved service total?

Recommended: make the basis configurable in Admin, with a default selected before launch.

## 2. Service scheduling rules
Scheduling is required.
Still needed:
- Available days/hours.
- Appointment slot duration.
- Same-day booking?
- Customer reschedule window.
- Cancellation/no-show rules.
- Technician availability model.

## 3. Courier details
Courier-partner model is confirmed.
Still needed:
- Initial courier partner(s).
- Delivery fee calculation.
- Free-delivery threshold, if any.
- COD reconciliation process.
- Tracking integration method.

## 4. Warranty/return defaults
Product/service-specific rules are confirmed.
Still needed:
- Default warranty templates.
- Used-product condition grades.
- Standard return windows where applicable.
- Which products/services are non-returnable, subject to applicable law.

## 5. WhatsApp/email providers
Channels confirmed: WhatsApp + email.
Still needed:
- WhatsApp provider/API.
- Email provider.
- Sender email/domain.
- Message templates.

## 6. Brand assets
A centralized theme is already defined in:
`packages/design-tokens/theme.json`

Current direction:
- Restrained orange: #E86F1C
- Black: #111111
- Warm off-white: #F7F4EF
- White surface: #FFFFFF

Logo and final font licensing/assets can be added later without changing product architecture.

## 7. Legal entity details
Before launch, add:
- Registered business/legal name.
- Address.
- Contact details.
- Registration/tax information as required.
- Final Terms, Privacy Policy, Warranty and Returns text.

Do not invent these details in the product.
