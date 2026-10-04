# Deployment & Operations

## Environments
- Development.
- Staging.
- Production.

Production data must never be used casually during development.

## Firebase
Configure:
- Auth.
- Firestore.
- Cloudinary (Image Storage).
- Storage.
- Functions.
- FCM.
- Hosting if selected.
- Security rules.
- Indexes.
- Environment/configuration values.

## Cloudinary (Image Storage)
Configure:
- Cloud Name: `esmfahf0`
- API Key and Secret (in environment variables, never hard-coded in public repos).
- Upload presets / signed uploads for secure client-side and server-side media assets.

## Backups
Define scheduled Firestore backups and Storage backup strategy before production launch.

## Monitoring
Monitor:
- Cloud Functions failures.
- Auth failures.
- Firestore usage.
- Storage usage.
- Notification failures.
- Error rates.
- Order/service workflow failures.

## CI/CD
Recommended:
- Version control.
- Automated tests.
- Lint/type checks.
- Staging deployment.
- Production deployment with approval.

## Secrets
Never commit secrets, service account keys or API credentials.
