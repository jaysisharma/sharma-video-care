// Confirmed Business Constants & Source of Truth
export const APP_NAME = "Sharma Video Care";
export const CORE_PROMISE = "Repair. Buy. Source. Install. Get It Done.";
export const TAGLINE_1 = "Quality Products. Reliable Service.";
export const TAGLINE_2 = "Fixing Cameras, Saving Memories.";

export const DEFAULT_SERVICE_AREA = "Janakpur";
export const REPAIR_PRICE_NOTICE = "Inspection required — final price after diagnosis.";

export const DEFAULT_SVC_COMMISSION_PCT = 90;
export const DEFAULT_TECH_COMMISSION_PCT = 10;
export const DEFAULT_CURRENCY = "NPR";
export const DEFAULT_INSPECTION_FEE = 0;
export const DEFAULT_VISIT_FEE = 0;

// User Roles & Auth
export type UserRole = "customer" | "admin" | "technician";
export type TechnicianType = "INTERNAL" | "EXTERNAL";

export interface UserProfile {
  id: string;
  role: UserRole;
  name: string;
  email: string;
  phone?: string;
  photoUrl?: string;
  status: "ACTIVE" | "INACTIVE" | "BLOCKED";
  technicianType?: TechnicianType;
  createdAt: string;
  updatedAt: string;
}

export interface CustomerAddress {
  id: string;
  label: string; // e.g. "Home", "Office"
  recipientName: string;
  phoneNumber: string;
  province?: string;
  city: string; // e.g. "Janakpur"
  wardNumber?: string;
  streetAddress: string;
  landmarks?: string;
  isDefault?: boolean;
}

export interface TechnicianRecord {
  userId: string;
  technicianType: TechnicianType;
  skills: string[];
  serviceAreas: string[];
  status: "AVAILABLE" | "ON_JOB" | "OFF_DUTY";
  ratingSummary?: {
    averageRating: number;
    totalReviews: number;
  };
}

// Service Catalogue & Requests
export interface ServiceCategory {
  id: string;
  name: string;
  slug: string;
  description: string;
  icon?: string;
  displayOrder: number;
  active: boolean;
}

export interface ServiceItem {
  id: string;
  categoryId: string;
  name: string;
  slug: string;
  description: string;
  commonProblems: string[];
  requiresInspection: boolean;
  active: boolean;
}

export type ServiceRequestType = "STANDARD" | "CUSTOM";

export type ServiceStatus =
  | "REQUESTED"
  | "UNDER_REVIEW"
  | "INSPECTION_SCHEDULED"
  | "INSPECTION_IN_PROGRESS"
  | "QUOTE_PENDING"
  | "QUOTE_SENT"
  | "CUSTOMER_APPROVED"
  | "IN_PROGRESS"
  | "WAITING_FOR_PARTS"
  | "COMPLETED"
  | "CANCELLED"
  | "CLOSED";

export interface ServiceRequest {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone?: string;
  categoryId?: string;
  categoryName?: string;
  serviceId?: string;
  serviceName?: string;
  type: ServiceRequestType;
  title: string;
  description: string;
  mediaUrls: string[];
  address: CustomerAddress;
  preferredSchedule?: {
    preferredDate: string;
    preferredTimeSlot?: string;
  };
  status: ServiceStatus;
  assignedTechnicianId?: string;
  assignedTechnicianName?: string;
  inspectionId?: string;
  quoteId?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

// Inspection & Diagnosis
export interface InspectionRecord {
  id: string;
  serviceRequestId: string;
  technicianId: string;
  technicianName: string;
  findings: string;
  diagnosis: string;
  recommendedWork: string;
  mediaUrls: string[];
  partsRequired: Array<{
    name: string;
    partNumber?: string;
    estimatedCost?: number;
  }>;
  estimatedLabourHours?: number;
  inspectionFee: number; // Always 0 by default
  completedAt: string;
}

// Quotes
export type QuoteStatus =
  | "DRAFT"
  | "SENT"
  | "ACCEPTED"
  | "REJECTED"
  | "EXPIRED"
  | "CANCELLED"
  | "SUPERSEDED";

export interface QuoteItem {
  id: string;
  description: string;
  type: "LABOUR" | "PART" | "FEE" | "DISCOUNT";
  amount: number;
}

export interface ServiceQuote {
  id: string;
  serviceRequestId: string;
  customerId: string;
  items: QuoteItem[];
  labourTotal: number;
  partsTotal: number;
  inspectionFee: number;
  visitFee: number;
  discount: number;
  total: number;
  currency: string;
  notes: string;
  warrantyTerms?: string;
  validUntil: string;
  status: QuoteStatus;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  acceptedAt?: string;
  rejectedAt?: string;
}

// Products & Sourcing
export type ProductAvailability =
  | "IN_STOCK"
  | "SOURCE_ON_REQUEST"
  | "SPECIAL_ORDER"
  | "OUT_OF_STOCK";

export interface ProductItem {
  id: string;
  categoryId: string;
  categoryName: string;
  name: string;
  brand: string;
  model: string;
  sku: string;
  description: string;
  price: number;
  availabilityType: ProductAvailability;
  stockQuantity: number;
  images: string[];
  specifications: Record<string, string>;
  warrantyInfo?: string;
  returnPolicyInfo?: string;
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export type UsedConditionGrade = "LIKE_NEW" | "EXCELLENT" | "GOOD" | "FAIR";

export interface UsedProductListing {
  id: string;
  name: string;
  brand: string;
  model: string;
  categoryName: string;
  conditionGrade: UsedConditionGrade;
  conditionDescription: string;
  knownDefects: string[];
  functionalTestStatus: "TESTED_FULLY_FUNCTIONAL" | "TESTED_WITH_LIMITATIONS";
  testNotes: string;
  includedAccessories: string[];
  warrantyDetails: string;
  returnEligibility: boolean;
  returnWindowDays: number;
  price: number;
  images: string[];
  serialNumberMasked?: string;
  stockQuantity: number; // usually 1
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface SourceRequest {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone?: string;
  productName: string;
  brandOrModel?: string;
  quantity: number;
  budget?: number;
  notes: string;
  referenceImages: string[];
  deliveryCity: string;
  status: "SUBMITTED" | "SOURCING" | "QUOTED" | "ACCEPTED" | "UNAVAILABLE" | "CANCELLED";
  quoteAmount?: number;
  quoteNotes?: string;
  createdAt: string;
  updatedAt: string;
}

// Commerce: Cart & Orders
export type PaymentMethod = "COD" | "BANK_TRANSFER";
export type PaymentStatus = "PENDING" | "PENDING_VERIFICATION" | "VERIFIED" | "REJECTED";

export type OrderStatus =
  | "PENDING_PAYMENT"
  | "PAYMENT_SUBMITTED"
  | "CONFIRMED"
  | "PROCESSING"
  | "READY_TO_DISPATCH"
  | "DISPATCHED"
  | "DELIVERED"
  | "CANCELLED"
  | "RETURN_REQUESTED"
  | "RETURNED"
  | "REFUNDED";

export interface OrderItem {
  productId: string;
  productType: "NEW" | "USED" | "SOURCED";
  name: string;
  image?: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  warrantySummary?: string;
}

export interface OrderRecord {
  id: string;
  customerId: string;
  customerName: string;
  customerPhone?: string;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  total: number;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  orderStatus: OrderStatus;
  shippingAddress: CustomerAddress;
  courierDetails?: {
    partnerName?: string;
    trackingNumber?: string;
    dispatchedAt?: string;
    deliveredAt?: string;
  };
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaymentProof {
  id: string;
  orderId: string;
  customerId: string;
  method: PaymentMethod;
  amount: number;
  referenceNumber: string;
  proofImageUrl?: string;
  status: PaymentStatus;
  submittedAt: string;
  verifiedBy?: string;
  verifiedAt?: string;
  rejectionReason?: string;
}

// Chat
export type ChatContextType = "SERVICE_REQUEST" | "ORDER" | "SOURCE_REQUEST" | "GENERAL_SUPPORT";

export interface Conversation {
  id: string;
  customerId: string;
  customerName: string;
  contextType: ChatContextType;
  contextId: string;
  contextTitle: string;
  participantIds: string[];
  assignedTechnicianId?: string;
  status: "OPEN" | "RESOLVED" | "CLOSED";
  lastMessageText?: string;
  lastMessageAt: string;
  unreadCountCustomer: number;
  unreadCountStaff: number;
}

export interface ChatMessage {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  senderRole: UserRole;
  text: string;
  attachmentUrls?: string[];
  createdAt: string;
}

// Settings
export interface CommercialSettings {
  currency: string;
  inspectionFee: number;
  visitFee: number;
  defaultRepairPricingNotice: string;
  sharmaVideoCareCommissionPct: number;
  externalTechnicianCommissionPct: number;
  externalTechnicianCommissionBasis: "LABOUR_ONLY" | "TOTAL_SERVICE";
  serviceAreaDefault: string;
  deliveryNationwideNepal: boolean;
  deliveryNationwideFeeDefault: number;
  bankAccountDetails?: {
    bankName: string;
    accountName: string;
    accountNumber: string;
    branchName?: string;
  };
}
