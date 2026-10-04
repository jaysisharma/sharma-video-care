# Sharma Video Care — Project Accounts, Credentials & Service Registry

This document serves as the permanent reference for all accounts, service providers, emails, and credentials used across the Sharma Video Care product so that team members and future maintainers never get confused.

---

## 1. Master Account Email

All cloud infrastructure, third-party media storage, and project services are registered under:

> **Primary Master Email:** `jaysisharma@gmail.com`

---

## 2. Service & Provider Registry

### A. Google Cloud & Firebase Backend
All authentication, Firestore database records, and security rules are provisioned under `jaysisharma@gmail.com`.

- **Google Account:** `jaysisharma@gmail.com`
- **Firebase Project ID:** `video-care-456d3`
- **Google Cloud Project Number:** `753503373289`
- **Firestore Database Region:** `asia-south1` (Mumbai — lowest latency to Nepal)
- **Database Type:** Cloud Firestore Native Mode
- **Web App ID:** `1:753503373289:web:5749dd73c9a70d76a82d78`
- **Android App ID:** `1:753503373289:android:36d19c8f642ec882a82d78` (Package: `com.sharmavideocare.app`, Config: `apps/mobile/android/app/google-services.json`)
- **iOS App ID:** `1:753503373289:ios:b31aca5b2c2efa64a82d78` (Bundle: `com.sharmavideocare.app`, Config: `apps/mobile/ios/Runner/GoogleService-Info.plist`)
- **Flutter Firebase Options:** `apps/mobile/lib/firebase_options.dart`
- **Auth Domain:** `video-care-456d3.firebaseapp.com`
- **Storage Bucket:** `video-care-456d3.firebasestorage.app`
- **Firebase API Key (Web):** `AIzaSyCvU-6LtUec49iLhk2AwcIlrjup2-jwX-4`
- **Firebase API Key (Android):** `AIzaSyCd6ciGTHx4mhBsiHpOvtAVHpTXhjYVx3Y`
- **Firebase API Key (iOS):** `AIzaSyAemoJMwqvVp9YkZ9rc-SeRAOP565SoOkM`

---

### B. Cloudinary (Image & Media Storage)
Used for all customer-uploaded defect evidence, equipment photos, payment deposit vouchers, and product catalogue imagery.

- **Account Email:** `jaysisharma@gmail.com`
- **Cloud Name:** `esmfahf0`
- **API Key:** `774116671947288`
- **API Secret:** `JnajHjdCoFjMtz6pYbuxk2n3F54`
- **Environment Variable Format:**
  ```env
  NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME=esmfahf0
  CLOUDINARY_API_KEY=774116671947288
  CLOUDINARY_API_SECRET=JnajHjdCoFjMtz6pYbuxk2n3F54
  CLOUDINARY_URL=cloudinary://774116671947288:JnajHjdCoFjMtz6pYbuxk2n3F54@esmfahf0
  ```

---

### C. Repository & Local Workspace
- **Workspace Directory:** `/Users/jaysisharma/Desktop/video_care`
- **Developer / Git Identity:** `jaysisharma@gmail.com`

---

### D. Operational & Business Entity Registry
- **Business Name:** Sharma Video Care
- **Core Operations Base:** Janakpur, Dhanusha, Madhesh Province, Nepal
- **Initial Repair Service Area:** Janakpur Sub-Metropolitan
- **Product Delivery Reach:** Nationwide Nepal (Courier Partners)
- **Primary Operational Support Email:** `jaysisharma@gmail.com` (forwarded/masked as `support@sharmavideocare.com`)
- **Primary Bank Account (Manual Wire/Voucher):**
  - Bank: Rastriya Banijya Bank
  - Branch: Janakpur Branch
  - Account Name: Sharma Video Care
  - Account Number: `10400019283748`

---

## 3. Summary Quick-Lookup Table

| Service | Email / Account Used | Identifier / Key Details | Role in Platform |
| :--- | :--- | :--- | :--- |
| **Firebase** | `jaysisharma@gmail.com` | `video-care-456d3` (753503373289) | Auth, Database, Security Rules |
| **Cloudinary** | `jaysisharma@gmail.com` | Cloud Name: `esmfahf0` | Media & Image Storage |
| **Git / Repo** | `jaysisharma@gmail.com` | Local MacOS Workspace | Source Code & Docs |
| **Business Admin**| `jaysisharma@gmail.com` | Sharma Video Care Admin Desk | Operational Owner |

*(Keep this file secure and reference whenever configuring new environments or deployment targets).*
