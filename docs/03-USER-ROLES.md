# User Roles & Permissions

## Customer
Can:
- Register/login.
- Manage profile and addresses.
- Browse services/products.
- Submit service requests.
- Upload evidence.
- Request custom services.
- Request products.
- Receive/view quotations.
- Accept/reject quotations.
- Place orders.
- Choose COD/bank transfer.
- View status.
- Chat with support/assigned technician/product seller.
- Review completed services/products.

Cannot:
- Access other customers' data.
- Modify official quotations.
- Assign technicians.
- Create products.

## Admin
Full operational control:
- Manage customers.
- Manage technicians.
- Manage services/categories.
- Manage products and used listings.
- Manage inventory.
- Review requests.
- Assign technicians.
- Create/approve quotations according to business rules.
- Manage orders/payments.
- Manage sourcing.
- Access support chats.
- Manage content/settings.
- View reports/audit logs.

## Technician
Can:
- See assigned jobs only.
- View necessary customer/service information.
- Update job status.
- Perform inspection.
- Record diagnosis.
- Upload evidence.
- Record parts/labour.
- Communicate through job chat.
- Submit completion information.

Cannot:
- Access unrelated customers/jobs.
- Change product catalogue.
- Change final commercial policy.
- Issue unrestricted quotations unless explicitly granted later.

## External technician
Same base technician permissions, with stricter access and assignment controls.

## Future role: Product Seller
Do not create as a separate authenticated role unless required. Initially product seller can be represented by Admin/Support permissions.


## Technician payout visibility
Technicians should see their own applicable payout information only. They must not see internal margin, customer acquisition cost, other technicians' payouts or unrelated financial information unless Admin explicitly grants permission.
