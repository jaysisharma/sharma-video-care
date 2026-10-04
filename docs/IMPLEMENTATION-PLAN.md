# Implementation Plan & Progress Status

## Phase 0 — Decisions & foundation [COMPLETED]
- [x] Finalize critical decisions and treat them as immutable source of truth.
- [x] Centralize brand & design tokens (`packages/design-tokens/theme.json`, `apps/web/theme.css`, `apps/mobile/theme_tokens.dart`).
- [x] Confirm frontend & monorepo stack (Next.js 14 App Router, Flutter, npm workspaces).
- [x] Provision live Firebase backend project (`video-care-456d3`) with Firestore Native database in `asia-south1`.
- [x] Configure Cloudinary for image and media storage (Cloud Name: `esmfahf0`, API Key: `774116671947288`).
- [x] Register Project Accounts & Credentials documentation (`docs/PROJECT-CREDENTIALS-AND-ACCOUNTS.md`) under master email `jaysisharma@gmail.com`.
- [x] Register Web app (`1:753503373289:web:5749dd73c9a70d76a82d78`) and Android app (`com.sharmavideocare.app`).
- [x] Configure authentication, demo persona test switching, and 3 explicit roles: Customer, Admin, Technician (Internal & External).

## Phase 1 — Core platform [COMPLETED]
- [x] User profiles and customer address models in `@sharmavideocare/shared`.
- [x] Live Firestore synchronization for active user profile.
- [x] Admin console scaffolding and technician portal scaffolding.
- [x] Firestore security rules deployed and verified with strict customer data isolation and technician job isolation.
- [x] Base layout, responsive navbar with persona switcher, and comprehensive footer conforming to Nepal e-commerce disclosures.

## Phase 2 — Services [COMPLETED]
- [x] Service catalogue populated in Firestore (`camera`, `lens`, `drone`, `cctv`, `tv`, `installation-setup`).
- [x] Service detail view with common fault checklist and free inspection CTA.
- [x] Standard service request form with Janakpur location, slot picker, and mandatory pricing acknowledgement (*"Inspection required — final price after diagnosis."*).
- [x] Custom service request form for mounting, audio setup, and specialized technical jobs.
- [x] Admin dispatch modal for assigning internal or external technicians.
- [x] Technician inspection & physical diagnosis modal recording findings, diagnosis, and parts required.
- [x] Itemized quotation preparation in Admin (Labour + Parts + Service Warranty, Rs. 0 inspection and visit fees).
- [x] Customer quotation approval & decline workflow with instant status update.
- [x] Technician job progression: `INSPECTION_IN_PROGRESS` → `QUOTE_PENDING` → `CUSTOMER_APPROVED` → `IN_PROGRESS` → `COMPLETED`.

## Phase 3 — Commerce [COMPLETED]
- [x] Product catalogue seeded in Firestore with search and category filtering.
- [x] Truthful inventory representation (`IN_STOCK`, `SOURCE_ON_REQUEST`, `OUT_OF_STOCK`).
- [x] Product detail view with pre-purchase disclosures for warranty and return policies.
- [x] Shopping cart with nationwide courier delivery calculations (Rs. 150).
- [x] Checkout supporting delivery across Nepal with Cash on Delivery (COD) and manual Bank Transfer.
- [x] Bank transfer deposit voucher / reference submission workflow.
- [x] Admin payment verification: reviewing transfer slip and approving/rejecting payments.
- [x] Courier dispatch: assigning courier partner (Nepal Can Move, Aramex, etc.) and tracking numbers.

## Phase 4 — Sourcing + used products [COMPLETED]
- [x] Source-on-Request form with zero-deposit procurement guarantee.
- [x] Sourcing quotation workflow in Admin and customer tracking.
- [x] Certified Second-Hand catalogue (exclusively listed and inspected by Sharma Video Care).
- [x] Mandatory condition grades (`LIKE_NEW`, `EXCELLENT`, `GOOD`), defect disclosures, and test notes.
- [x] Second-hand purchase with specific service warranties and 7-day return windows.

## Phase 5 — Chat & notifications [COMPLETED]
- [x] Realtime context-linked conversations in Firestore.
- [x] Context linking for Service Requests, Orders, and Sourcing Requests.
- [x] Chat UI supporting role badges (Customer, Admin, Technician) and attachments.
- [x] Multi-participant support linking assigned technician to customer job chat.

## Phase 6 — Mobile [COMPLETED]
- [x] Flutter workspace and dependencies configured in `apps/mobile/pubspec.yaml`.
- [x] Single-source design system tokens integrated via `apps/mobile/theme_tokens.dart` (`SvcColors`, `SvcTheme`).
- [x] State management & live persona switching in `apps/mobile/lib/state/app_state.dart`.
- [x] Full customer mobile screens: Home, Service Booking (with Janakpur location & pricing notice), Store Catalogue, Certified Pre-Owned (with defect disclosures), Source-on-Request (zero deposit), Cart & Checkout.
- [x] Customer Account with quotation approval (**Approve** / **Decline**) and courier tracking.
- [x] Technician mobile portal (`TechnicianPortalScreen`) with assigned jobs isolation, 10% contract commission rate display, diagnosis recording modal, and job completion.
- [x] Context-linked mobile chat thread (`ChatScreen`).

## Phase 7 — Authentication & Security Hardening [COMPLETED]
- [x] Clean, professional, minimal Authentication Suite:
  - Sign In (`/login`) with email/password, error handling, session persistence, and 1-click developer test credentials.
  - Registration (`/register`) with full name, Nepal phone verification formatting, email, password, and Terms agreement.
  - Password Recovery (`/forgot-password`) with automated reset email dispatch.
  - Account Profile (`/account`) with user details, role badge, session sign-out, and active tracking tabs.
- [x] Role Guards:
  - Admin operations console guarded against unauthorized visitors with clean access notice.
  - Technician portal guarded against non-technician users.
- [x] Zero AI Slop / Zero Pill Chips:
  - Eliminated all pill chips (`border-radius: 9999px`) in favor of crisp rectangular tags (`border-radius: 4px`) aligned with design tokens.
- [x] Seeded core user records in live Firestore (`admin-svc-01`, `tech-svc-int-01`, `tech-svc-ext-01`, `cust-janakpur-01`).
- [x] Full Next.js production build (`npm --workspace=apps/web run build`) passed with 22 static and dynamic routes.

## Phase 8 — Launch Readiness
- [x] Commercial split configuration operational in Admin console (default 90% Sharma Video Care / 10% External Technician).
- [x] Live database seeded with core categories, products, and certified pre-owned units.
- [ ] Production domain connection and final legal counsel review.
