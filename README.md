# Sharma Video Care — Antigravity Project Documentation

This repository is the product specification and implementation source of truth for Sharma Video Care.

## Confirmed stack
- Web: Next.js
- Mobile: Flutter
- Backend: Firebase
- Auth: Firebase Authentication
- Database: Cloud Firestore
- Image storage: Cloudinary (cloud: esmfahf0)
- Files & assets: Cloud Storage / Cloudinary
- Server logic: Cloud Functions
- Notifications: WhatsApp + email
- Payments: COD + bank transfer
- Delivery: courier partners

## Confirmed business model
- Repair/service: Janakpur initially.
- Product delivery: nationwide Nepal.
- Inspection: free.
- Visit: free.
- Repair quote: after diagnosis.
- External technician split: 90% Sharma Video Care / 10% technician, configurable in Admin.
- Warranty/returns: product/service-specific.
- Second-hand: Sharma Video Care only.
- Product sourcing: internal, no customer deposit initially.
- Chat: customer ↔ responsible team/technician/product support.

## Source of truth
1. Explicit confirmed decisions.
2. Business rules.
3. PRD.
4. Architecture.
5. Design system.

If a critical decision remains open, do not invent it.

## Theme
Use:
`packages/design-tokens/theme.json`

Web:
`apps/web/theme.css`

Flutter:
`apps/mobile/theme_tokens.dart`

All screens/components must consume these tokens.

## Legal note
The legal draft is an implementation starting point, not a substitute for legal review. The current draft is based on the Nepal Law Commission's published Electronic Commerce Act 2081, Consumer Protection Act 2075 and Privacy Act 2075, but final legal text should be reviewed for the actual business.

## CI/CD — Android APK Build Pipeline

A GitHub Actions workflow is located at `.github/workflows/build-apk.yml` to automate building and distributing the Flutter Android APK.

### Automated Triggers
- **Push to `main`**: Automatically triggers whenever changes to `apps/mobile/**` are pushed.
- **Pull Requests to `main`**: Runs analysis, tests, and builds to verify that pull requests do not break the Android build.
- **Release Tags (`v*`)**: Automatically creates a GitHub Release with the generated APK(s) attached.
- **Manual Trigger (`workflow_dispatch`)**: Trigger directly from the **Actions** tab on GitHub:
  - Select build mode (`release` or `debug`).
  - Option to split APK per ABI (`arm64-v8a`, `armeabi-v7a`, `x86_64`).
  - Option to toggle analyzer & tests.

### Downloading Built APKs
1. Go to your repository on GitHub and click the **Actions** tab.
2. Select the latest **Build Android APK** workflow run.
3. Scroll down to the **Artifacts** section at the bottom of the summary page.
4. Click on **release-apk** (or debug-apk) to download the APK.

### Production Release Signing (Optional)
If you wish to sign APKs with your production upload keystore instead of the default debug signing, configure the following secrets in GitHub (**Settings > Secrets and variables > Actions**):
- `ANDROID_KEYSTORE_BASE64`: Base64 string of your `.jks` / `.keystore` file (`base64 -i upload-keystore.jks`).
- `ANDROID_KEYSTORE_PASSWORD`: Password for your keystore.
- `ANDROID_KEY_ALIAS`: Key alias name.
- `ANDROID_KEY_PASSWORD`: Password for the key.
