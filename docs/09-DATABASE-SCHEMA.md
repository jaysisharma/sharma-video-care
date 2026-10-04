# Database Schema — Firestore

## User
- id
- role
- name
- email
- phone
- photoUrl
- status
- createdAt
- updatedAt

## Customer profile
- userId
- addresses[]
- preferences
- serviceHistorySummary

## Technician
- userId
- technicianType: INTERNAL | EXTERNAL
- skills[]
- serviceAreas[]
- status
- availability
- documents/verification metadata
- ratingSummary

## Service request
- id
- customerId
- categoryId
- serviceId
- type: STANDARD | CUSTOM
- title
- description
- media[]
- addressId
- preferredSchedule
- status
- assignedTechnicianId
- inspectionId
- quoteId
- createdAt
- updatedAt

## Inspection
- id
- serviceRequestId
- technicianId
- findings
- diagnosis
- recommendedWork
- media[]
- partsRequired[]
- estimatedLabour
- inspectionFee
- completedAt

## Quote
- id
- serviceRequestId
- customerId
- items[]
- labour
- parts
- fees
- discount
- total
- currency
- notes
- validUntil
- status
- createdBy
- acceptedAt/rejectedAt

## Product
- id
- categoryId
- name
- brand
- model
- sku
- description
- price
- availabilityType
- stockQuantity
- images[]
- specifications
- active
- createdAt
- updatedAt

## Used product
- productId
- conditionGrade
- conditionDescription
- defects[]
- tested
- testNotes
- includedAccessories[]
- warranty
- ownership/status metadata
- images[]

## Source request
- id
- customerId
- requestedProduct
- quantity
- budget
- notes
- media[]
- status
- quoteId

## Order
- id
- customerId
- items[]
- subtotal
- deliveryFee
- discount
- total
- paymentMethod
- paymentStatus
- orderStatus
- shippingAddress
- createdAt
- updatedAt

## Payment
- id
- orderId
- method: COD | BANK_TRANSFER
- amount
- reference
- proofUrl
- status
- verifiedBy
- verifiedAt

## Conversation
- id
- customerId
- contextType
- contextId
- participantIds[]
- status
- lastMessageAt

## Message
- id
- conversationId
- senderId
- type
- text
- attachments[]
- createdAt
- readBy[]

All timestamps should be server timestamps where possible.
