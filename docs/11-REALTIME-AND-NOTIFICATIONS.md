# Realtime & Notifications

## Realtime
Use Firestore realtime listeners for:
- Chat.
- Order status.
- Service status.
- Quote status.
- Technician assignment.
- Notifications.

## Push notifications
Firebase Cloud Messaging.

Important events:
- New service request received by staff.
- Technician assigned.
- Inspection scheduled.
- Diagnosis completed.
- Quote sent.
- Quote accepted/rejected.
- Order confirmed.
- Bank transfer verified.
- Order dispatched.
- Order delivered.
- New chat message.
- Job completed.
- Source request updated.

Notification rules:
- Avoid duplicate notifications.
- Respect notification preferences where applicable.
- Do not send sensitive details in notification previews unnecessarily.
