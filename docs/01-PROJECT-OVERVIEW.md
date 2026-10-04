# Sharma Video Care — Project Overview

## Product vision
Sharma Video Care is one integrated service + commerce platform for repair, custom service enquiries, product sales, sourced-on-request products, and Sharma Video Care-owned second-hand products.

**Core promise:** Repair. Buy. Source. Install. Get It Done.

## Confirmed platform decisions
- Customer website: **Next.js**
- Customer mobile app: **Flutter**
- Backend: **Firebase**
- Users: **Customer + Admin + Technician**
- Repair/service area initially: **Janakpur**
- Product delivery: **nationwide Nepal**, using courier partners
- Payments initially: **COD + bank transfer**
- Technicians: Sharma Video Care technicians + external technicians
- External technician commercial split: **Sharma Video Care 90% / technician 10%**, configurable from Admin
- Inspection fee: **Free**
- Visit fee: **Free**
- Repair quotation: **after diagnosis/inspection**
- Warranty/returns: **vary by product and service/work**
- Second-hand: only Sharma Video Care sells/list products
- Sourcing: no customer deposit initially; internal procurement process
- Chat: customer can chat with the team associated with the query (Support/Admin, assigned Technician, or Product Seller/assigned product team)
- Notifications: **WhatsApp + email**; no SMS initially
- Image storage: **Cloudinary** (cloud: `esmfahf0`) for customer media, products, and verification slips.
- Website is the first public customer experience; mobile apps remain part of the complete product scope.

## Service categories
Camera, lens, drone, CCTV, TV, AC, refrigerator, washing machine, laptop, mobile, electronics, home appliances, installation/setup and other services.

Categories must be Admin-configurable.

## Commerce
New products, accessories and equipment are sold through the catalogue. If an item is not currently stocked, Sharma Video Care may source it internally and provide the customer a quote/request-based availability without falsely claiming that it is physically in stock.

## Second-hand
Only Sharma Video Care lists and sells used products. Each used item must have condition information, testing/inspection details, included accessories and applicable warranty/return rules.

## Initial non-goals
- Open third-party seller marketplace.
- Customer-to-customer used marketplace.
- Customer deposits for sourcing.
- SMS notifications.
- Online card/wallet payment gateway.
