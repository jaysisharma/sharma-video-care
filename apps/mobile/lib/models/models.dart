// User & Demo Personas
class DemoPersona {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'admin' | 'technician'
  final String? technicianType; // 'INTERNAL' | 'EXTERNAL'
  final String label;

  const DemoPersona({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.technicianType,
    required this.label,
  });
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'admin' | 'technician'
  final String? technicianType; // 'INTERNAL' | 'EXTERNAL'
  final String status;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.technicianType,
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  factory UserModel.fromPersona(DemoPersona p) {
    return UserModel(
      id: p.id,
      name: p.name,
      email: p.email,
      phone: p.phone,
      role: p.role,
      technicianType: p.technicianType,
      status: 'ACTIVE',
      createdAt: DateTime.now(),
    );
  }
}

const List<DemoPersona> kDemoPersonas = [
  DemoPersona(
    id: 'cust-janakpur-01',
    name: 'Ramesh Sah',
    email: 'ramesh@example.com',
    phone: '+977-9801234567',
    role: 'customer',
    label: 'Customer (Ramesh - Janakpur)',
  ),
  DemoPersona(
    id: 'admin-svc-01',
    name: 'Sharma Admin',
    email: 'admin@sharmavideocare.com',
    phone: '+977-9851000000',
    role: 'admin',
    label: 'Admin (Operations & Dispatch)',
  ),
  DemoPersona(
    id: 'tech-svc-int-01',
    name: 'Bikash Sharma',
    email: 'bikash.tech@sharmavideocare.com',
    phone: '+977-9844001122',
    role: 'technician',
    technicianType: 'INTERNAL',
    label: 'Internal Tech (Bikash - Camera)',
  ),
  DemoPersona(
    id: 'tech-svc-ext-01',
    name: 'Sunil Mandal',
    email: 'sunil.mandal@example.com',
    phone: '+977-9812334455',
    role: 'technician',
    technicianType: 'EXTERNAL',
    label: 'External Tech (Sunil - Appliances)',
  ),
];

// Service Category
class ServiceCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int displayOrder;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.displayOrder,
  });

  factory ServiceCategoryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ServiceCategoryModel(
      id: id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      displayOrder: (data['displayOrder'] ?? 0) is int ? data['displayOrder'] : int.tryParse(data['displayOrder'].toString()) ?? 0,
    );
  }
}

// Service Request
class ServiceRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String title;
  final String description;
  final String status;
  final String city;
  final String streetAddress;
  final String preferredDate;
  final String preferredTimeSlot;
  final String? assignedTechnicianId;
  final String? assignedTechnicianName;
  final String? quoteId;
  final String? inspectionId;
  final DateTime createdAt;

  ServiceRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.title,
    required this.description,
    required this.status,
    required this.city,
    required this.streetAddress,
    required this.preferredDate,
    required this.preferredTimeSlot,
    this.assignedTechnicianId,
    this.assignedTechnicianName,
    this.quoteId,
    this.inspectionId,
    required this.createdAt,
  });

  factory ServiceRequestModel.fromFirestore(String id, Map<String, dynamic> data) {
    final addr = data['address'] as Map<String, dynamic>? ?? {};
    final sched = data['preferredSchedule'] as Map<String, dynamic>? ?? {};

    return ServiceRequestModel(
      id: id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'REQUESTED',
      city: addr['city'] ?? 'Janakpur',
      streetAddress: addr['streetAddress'] ?? '',
      preferredDate: sched['preferredDate'] ?? '',
      preferredTimeSlot: sched['preferredTimeSlot'] ?? 'Morning',
      assignedTechnicianId: data['assignedTechnicianId'],
      assignedTechnicianName: data['assignedTechnicianName'],
      quoteId: data['quoteId'],
      inspectionId: data['inspectionId'],
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// Service Quote
class ServiceQuoteModel {
  final String id;
  final String serviceRequestId;
  final int labourTotal;
  final int partsTotal;
  final int total;
  final String status; // 'SENT' | 'ACCEPTED' | 'REJECTED'
  final String warrantyTerms;
  final String notes;

  ServiceQuoteModel({
    required this.id,
    required this.serviceRequestId,
    required this.labourTotal,
    required this.partsTotal,
    required this.total,
    required this.status,
    required this.warrantyTerms,
    required this.notes,
  });

  factory ServiceQuoteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ServiceQuoteModel(
      id: id,
      serviceRequestId: data['serviceRequestId'] ?? '',
      labourTotal: (data['labourTotal'] ?? 0) is int ? data['labourTotal'] : int.tryParse(data['labourTotal'].toString()) ?? 0,
      partsTotal: (data['partsTotal'] ?? 0) is int ? data['partsTotal'] : int.tryParse(data['partsTotal'].toString()) ?? 0,
      total: (data['total'] ?? 0) is int ? data['total'] : int.tryParse(data['total'].toString()) ?? 0,
      status: data['status'] ?? 'SENT',
      warrantyTerms: data['warrantyTerms'] ?? 'Service Warranty applies',
      notes: data['notes'] ?? '',
    );
  }
}

// Product
class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String categoryName;
  final int price;
  final String availabilityType; // 'IN_STOCK' | 'SOURCE_ON_REQUEST'
  final int stockQuantity;
  final String description;
  final String? imageUrl;
  final String warrantyInfo;
  final String returnPolicyInfo;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryName,
    required this.price,
    required this.availabilityType,
    required this.stockQuantity,
    required this.description,
    this.imageUrl,
    required this.warrantyInfo,
    required this.returnPolicyInfo,
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    final images = data['images'] as List<dynamic>? ?? [];
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      categoryName: data['categoryName'] ?? '',
      price: (data['price'] ?? 0) is int ? data['price'] : int.tryParse(data['price'].toString()) ?? 0,
      availabilityType: data['availabilityType'] ?? 'IN_STOCK',
      stockQuantity: (data['stockQuantity'] ?? 0) is int ? data['stockQuantity'] : int.tryParse(data['stockQuantity'].toString()) ?? 0,
      description: data['description'] ?? '',
      imageUrl: images.isNotEmpty ? images[0].toString() : null,
      warrantyInfo: data['warrantyInfo'] ?? 'Manufacturer Warranty',
      returnPolicyInfo: data['returnPolicyInfo'] ?? 'Standard Return Terms',
    );
  }
}

// Used Product
class UsedProductModel {
  final String id;
  final String name;
  final String brand;
  final String conditionGrade;
  final String conditionDescription;
  final int price;
  final List<String> knownDefects;
  final String testNotes;
  final List<String> includedAccessories;
  final String warrantyDetails;
  final String? imageUrl;

  UsedProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.conditionGrade,
    required this.conditionDescription,
    required this.price,
    required this.knownDefects,
    required this.testNotes,
    required this.includedAccessories,
    required this.warrantyDetails,
    this.imageUrl,
  });

  factory UsedProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    final images = data['images'] as List<dynamic>? ?? [];
    final defects = (data['knownDefects'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final accs = (data['includedAccessories'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return UsedProductModel(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      conditionGrade: data['conditionGrade'] ?? 'EXCELLENT',
      conditionDescription: data['conditionDescription'] ?? '',
      price: (data['price'] ?? 0) is int ? data['price'] : int.tryParse(data['price'].toString()) ?? 0,
      knownDefects: defects,
      testNotes: data['testNotes'] ?? '',
      includedAccessories: accs,
      warrantyDetails: data['warrantyDetails'] ?? 'Sharma Video Care Limited Warranty',
      imageUrl: images.isNotEmpty ? images[0].toString() : null,
    );
  }
}

// Order & Cart Item
class CartItemModel {
  final String productId;
  final String productType; // 'NEW' | 'USED'
  final String name;
  final int unitPrice;
  int quantity;
  final String? imageUrl;

  CartItemModel({
    required this.productId,
    required this.productType,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
    this.imageUrl,
  });

  int get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String customerId;
  final int total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String city;
  final String streetAddress;
  final String itemsSummary;
  final String? courierPartner;
  final String? trackingNumber;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.city,
    this.streetAddress = '',
    this.itemsSummary = '',
    this.courierPartner,
    this.trackingNumber,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(String id, Map<String, dynamic> data) {
    final addr = data['shippingAddress'] as Map<String, dynamic>? ?? {};
    final courier = data['courierDetails'] as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final itemsSummary = rawItems.map((i) {
      if (i is Map) {
        return '${i['name'] ?? 'Product'} (x${i['quantity'] ?? 1})';
      }
      return i.toString();
    }).join(', ');

    return OrderModel(
      id: id,
      customerId: data['customerId'] ?? '',
      total: (data['total'] ?? 0) is int ? data['total'] : int.tryParse(data['total'].toString()) ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'COD',
      paymentStatus: data['paymentStatus'] ?? 'PENDING',
      orderStatus: data['orderStatus'] ?? 'CONFIRMED',
      city: data['city'] ?? addr['city'] ?? 'Janakpur',
      streetAddress: data['streetAddress'] ?? addr['streetAddress'] ?? '',
      itemsSummary: itemsSummary,
      courierPartner: courier['partnerName'],
      trackingNumber: courier['trackingNumber'],
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// Chat Message
class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.attachmentUrls,
    required this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(String id, Map<String, dynamic> data) {
    final att = (data['attachmentUrls'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return ChatMessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? 'customer',
      text: data['text'] ?? '',
      attachmentUrls: att,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// Source Request
class SourceRequestModel {
  final String id;
  final String customerId;
  final String itemDescription;
  final String budget;
  final String city;
  final String status;
  final String notes;
  final int advanceDeposit;
  final DateTime createdAt;

  SourceRequestModel({
    required this.id,
    required this.customerId,
    required this.itemDescription,
    required this.budget,
    required this.city,
    required this.status,
    required this.notes,
    required this.advanceDeposit,
    required this.createdAt,
  });

  factory SourceRequestModel.fromFirestore(String id, Map<String, dynamic> data) {
    return SourceRequestModel(
      id: id,
      customerId: data['customerId'] ?? '',
      itemDescription: data['itemDescription'] ?? data['title'] ?? '',
      budget: data['budget'] ?? '',
      city: data['city'] ?? 'Janakpur',
      status: data['status'] ?? 'SUBMITTED',
      notes: data['notes'] ?? '',
      advanceDeposit: (data['advanceDeposit'] ?? 0) is int
          ? data['advanceDeposit']
          : int.tryParse(data['advanceDeposit'].toString()) ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
