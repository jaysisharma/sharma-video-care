# API / Service Contracts

Firebase is the backend, but client applications should still use centralized callable/HTTP Cloud Functions for sensitive business operations.

## Core operations

Authentication
- signUp/signIn handled through Firebase Auth.

Service
- createServiceRequest
- updateServiceRequest
- assignTechnician
- createInspection
- submitDiagnosis
- createQuote
- sendQuote
- acceptQuote
- rejectQuote
- completeJob

Products
- createProduct
- updateProduct
- updateInventory
- createUsedProduct
- createSourceRequest
- createSourceQuote

Orders
- createOrder
- verifyPayment
- updateOrderStatus
- cancelOrder
- recordDelivery

Chat
- createConversation
- sendMessage
- markRead
- closeConversation

Notifications
- sendCustomerNotification
- sendTechnicianNotification

Every sensitive operation must validate:
- authentication.
- role.
- resource ownership/assignment.
- allowed state transition.
- input validation.
- audit logging where applicable.

Error format:
{
  code,
  message,
  userMessage,
  details?,
  requestId?
}

Do not expose stack traces or sensitive internal errors to customers.
