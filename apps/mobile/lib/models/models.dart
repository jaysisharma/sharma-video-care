import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore numbers may arrive as int, double or string (or be missing);
/// anything unreadable becomes 0 instead of throwing.
int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return num.tryParse(value.trim())?.toInt() ?? 0;
  return 0;
}

/// Text fields may hold a number or be missing (data entered on the website or
/// in the console); anything non-null is shown as text instead of throwing.
String _str(dynamic value, [String fallback = '']) => value == null ? fallback : value.toString();
String? _strOrNull(dynamic value) => value?.toString();

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

/// Firestore dates may be a Timestamp or an ISO-8601 string (the web admin
/// writes strings); anything else is treated as missing. Always local time, so
/// UTC strings ("...Z") display in the device's timezone.
DateTime? _asDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value)?.toLocal();
  return null;
}

// User Profile Model
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

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: _str(data['name']),
      email: _str(data['email']),
      phone: _str(data['phone']),
      role: _str(data['role'], 'customer'),
      technicianType: _strOrNull(data['technicianType']),
      status: _str(data['status'], 'ACTIVE'),
      createdAt: _asDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      if (technicianType != null) 'technicianType': technicianType,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? technicianType,
    String? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      technicianType: technicianType ?? this.technicianType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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
      name: _str(data['name']),
      slug: _str(data['slug']),
      description: _str(data['description']),
      displayOrder: _asInt(data['displayOrder']),
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
    final addr = _asMap(data['address']);
    final sched = _asMap(data['preferredSchedule']);

    return ServiceRequestModel(
      id: id,
      customerId: _str(data['customerId']),
      customerName: _str(data['customerName']),
      customerPhone: _str(data['customerPhone']),
      title: _str(data['title']),
      description: _str(data['description']),
      status: _str(data['status'], 'REQUESTED'),
      city: _str(addr['city'], 'Janakpur'),
      streetAddress: _str(addr['streetAddress']),
      preferredDate: _str(sched['preferredDate']),
      preferredTimeSlot: _str(sched['preferredTimeSlot'], 'Morning'),
      assignedTechnicianId: _strOrNull(data['assignedTechnicianId']),
      assignedTechnicianName: _strOrNull(data['assignedTechnicianName']),
      quoteId: _strOrNull(data['quoteId']),
      inspectionId: _strOrNull(data['inspectionId']),
      createdAt: _asDate(data['createdAt']) ?? DateTime.now(),
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
      serviceRequestId: _str(data['serviceRequestId']),
      labourTotal: _asInt(data['labourTotal']),
      partsTotal: _asInt(data['partsTotal']),
      total: _asInt(data['total']),
      status: _str(data['status'], 'SENT'),
      warrantyTerms: _str(data['warrantyTerms'], 'Service Warranty applies'),
      notes: _str(data['notes']),
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
  final int? originalPrice; // list price before discount; null when not on sale
  final String availabilityType; // 'IN_STOCK' | 'SOURCE_ON_REQUEST' | 'SPECIAL_ORDER' | 'OUT_OF_STOCK'
  final int stockQuantity;
  final String description;
  final String? imageUrl;
  final String warrantyInfo;
  final String returnPolicyInfo;
  final bool isFlashDeal;
  final DateTime? flashDealEndsAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    required this.availabilityType,
    required this.stockQuantity,
    required this.description,
    this.imageUrl,
    required this.warrantyInfo,
    required this.returnPolicyInfo,
    this.isFlashDeal = false,
    this.flashDealEndsAt,
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawImages = data['images'];
    final List<String> images = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : (rawImages is String && rawImages.isNotEmpty ? [rawImages] : const <String>[]);
    final fallbackImage = data['imageUrl']?.toString();
    return ProductModel(
      id: id,
      name: _str(data['name']),
      brand: _str(data['brand']),
      categoryName: _str(data['categoryName']),
      price: _asInt(data['price']),
      originalPrice: data['originalPrice'] == null ? null : _asInt(data['originalPrice']),
      availabilityType: _str(data['availabilityType'], 'IN_STOCK'),
      stockQuantity: _asInt(data['stockQuantity']),
      description: _str(data['description']),
      imageUrl: images.isNotEmpty ? images[0] : (fallbackImage != null && fallbackImage.isNotEmpty ? fallbackImage : null),
      warrantyInfo: _str(data['warrantyInfo'], 'Manufacturer Warranty'),
      returnPolicyInfo: _str(data['returnPolicyInfo'], 'Standard Return Terms'),
      isFlashDeal: data['isFlashDeal'] == true,
      flashDealEndsAt: _asDate(data['flashDealEndsAt']),
    );
  }

  /// A flash deal is live while it's flagged, discounted, in stock and its
  /// end time is still in the future.
  bool isLiveFlashDeal(DateTime now) =>
      isFlashDeal &&
      hasDiscount &&
      !isOutOfStock &&
      flashDealEndsAt != null &&
      flashDealEndsAt!.isAfter(now);

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Whole-number percent off the list price, or 0 when not on sale.
  int get discountPercent =>
      hasDiscount ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;

  bool get isOutOfStock => availabilityType == 'OUT_OF_STOCK';
}

// Used Product
class UsedProductModel {
  final String id;
  final String name;
  final String brand;
  final String? model;
  final String categoryName;
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
    this.model,
    this.categoryName = 'Cameras',
    required this.conditionGrade,
    required this.conditionDescription,
    required this.price,
    required this.knownDefects,
    required this.testNotes,
    this.includedAccessories = const [],
    required this.warrantyDetails,
    this.imageUrl,
  });

  factory UsedProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawImages = data['images'];
    final List<String> images = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : (rawImages is String && rawImages.isNotEmpty ? [rawImages] : const <String>[]);
    final rawDefects = data['knownDefects'];
    final List<String> defects = rawDefects is List
        ? rawDefects.map((e) => e.toString()).toList()
        : const <String>[];
    final rawAccs = data['includedAccessories'];
    final List<String> accs = rawAccs is List
        ? rawAccs.map((e) => e.toString()).toList()
        : const <String>[];
    final fallbackImage = data['imageUrl']?.toString();

    return UsedProductModel(
      id: id,
      name: _str(data['name']),
      brand: _str(data['brand']),
      model: data['model']?.toString(),
      categoryName: _str(data['categoryName'], 'Cameras'),
      conditionGrade: _str(data['conditionGrade'], 'EXCELLENT'),
      conditionDescription: _str(data['conditionDescription']),
      price: _asInt(data['price']),
      knownDefects: defects,
      testNotes: _str(data['testNotes']),
      includedAccessories: accs,
      warrantyDetails: _str(data['warrantyDetails'], 'QuickySewa Limited Warranty'),
      imageUrl: images.isNotEmpty ? images[0] : (fallbackImage != null && fallbackImage.isNotEmpty ? fallbackImage : null),
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

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productType': productType,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        productId: _str(map['productId']),
        productType: _str(map['productType'], 'NEW'),
        name: _str(map['name']),
        unitPrice: _asInt(map['unitPrice']),
        quantity: _asInt(map['quantity']).clamp(1, 99),
        imageUrl: _strOrNull(map['imageUrl']),
      );
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
    final addr = _asMap(data['shippingAddress']);
    final courier = _asMap(data['courierDetails']);
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final itemsSummary = rawItems.map((i) {
      if (i is Map) {
        return '${i['name'] ?? 'Product'} (x${i['quantity'] ?? 1})';
      }
      return i.toString();
    }).join(', ');

    return OrderModel(
      id: id,
      customerId: _str(data['customerId']),
      total: _asInt(data['total']),
      paymentMethod: _str(data['paymentMethod'], 'COD'),
      paymentStatus: _str(data['paymentStatus'], 'PENDING'),
      orderStatus: _str(data['orderStatus'], 'PENDING_PAYMENT'), // never claim confirmed
      city: _str(data['city'] ?? addr['city'], 'Janakpur'),
      streetAddress: _str(data['streetAddress'] ?? addr['streetAddress'], ''),
      itemsSummary: itemsSummary,
      courierPartner: _strOrNull(courier['partnerName']),
      trackingNumber: _strOrNull(courier['trackingNumber']),
      createdAt: _asDate(data['createdAt']) ?? DateTime.now(),
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
      senderId: _str(data['senderId']),
      senderName: _str(data['senderName']),
      senderRole: _str(data['senderRole'], 'customer'),
      text: _str(data['text']),
      attachmentUrls: att,
      createdAt: _asDate(data['createdAt']) ?? DateTime.now(),
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
      customerId: _str(data['customerId']),
      itemDescription: _str(data['itemDescription'] ?? data['title']),
      budget: _str(data['budget']), // the website stores a number
      city: _str(data['city'], 'Janakpur'),
      status: _str(data['status'], 'SUBMITTED'),
      notes: _str(data['notes']),
      advanceDeposit: _asInt(data['advanceDeposit']), // missing on web-created requests
      createdAt: _asDate(data['createdAt']) ?? DateTime.now(),
    );
  }
}

// Delivery Hub Model
class DeliveryHub {
  final String id;
  final String name;
  final String city;
  final String address;
  final String estimatedDelivery;
  final bool isDefault;

  const DeliveryHub({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.estimatedDelivery,
    this.isDefault = false,
  });
}

const List<DeliveryHub> kNepalDeliveryHubs = [
  DeliveryHub(
    id: 'hub-jkr',
    name: 'Janakpur Hub',
    city: 'Janakpurdham',
    address: 'Station Road, Near Bhanu Chowk',
    estimatedDelivery: 'Same-day pickup / 24h courier',
    isDefault: true,
  ),
  DeliveryHub(
    id: 'hub-ktm',
    name: 'Kathmandu Hub',
    city: 'Kathmandu',
    address: 'New Road Camera Market, Pako',
    estimatedDelivery: 'Next-day express delivery',
  ),
  DeliveryHub(
    id: 'hub-bir',
    name: 'Biratnagar Hub',
    city: 'Biratnagar',
    address: 'Main Road, Traffic Chowk',
    estimatedDelivery: '1-2 business days',
  ),
  DeliveryHub(
    id: 'hub-pok',
    name: 'Pokhara Hub',
    city: 'Pokhara',
    address: 'Lakeside Center, Ward 6',
    estimatedDelivery: '1-2 business days',
  ),
  DeliveryHub(
    id: 'hub-cht',
    name: 'Chitwan Hub',
    city: 'Bharatpur',
    address: 'Lions Chowk, Narayangarh',
    estimatedDelivery: '24-48 hours delivery',
  ),
  DeliveryHub(
    id: 'hub-btw',
    name: 'Butwal Hub',
    city: 'Butwal',
    address: 'Traffic Chowk, Milan Chowk',
    estimatedDelivery: '1-2 business days',
  ),
];

// Notification Item Model
class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String category; // 'orders' | 'repairs' | 'offers' | 'system'
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute; // 'shop' | 'services' | 'tradein' | 'account' | 'cart'
  final String? actionLabel;
  final String? targetGroup; // 'all' | 'users' | 'guest' | 'specific'
  final String? imageUrl;
  final String? userId;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.actionLabel,
    this.targetGroup = 'all',
    this.imageUrl,
    this.userId,
  });

  /// Read state is per viewer: [viewerId] is in `readBy`, or (for a notification
  /// addressed to the viewer alone) the legacy `isRead`/`read` flag is set.
  /// Guests (no [viewerId]) keep their read state on the device only.
  factory NotificationItemModel.fromFirestore(String id, Map<String, dynamic> data, {String? viewerId}) {
    final parsedDate = _asDate(data['createdAt'] ?? data['timestamp']) ?? DateTime.now();
    final readBy = data['readBy'];
    final isPersonal = viewerId != null && data['userId'] == viewerId;

    return NotificationItemModel(
      id: id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      category: data['category']?.toString() ?? 'system',
      timestamp: parsedDate,
      isRead: (viewerId != null && readBy is List && readBy.contains(viewerId)) ||
          (isPersonal && (data['isRead'] == true || data['read'] == true)),
      actionRoute: data['actionRoute']?.toString(),
      actionLabel: data['actionLabel']?.toString(),
      targetGroup: data['targetGroup']?.toString() ?? 'all',
      imageUrl: data['imageUrl']?.toString(),
      userId: data['userId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'category': category,
      'targetGroup': targetGroup ?? 'all',
      'actionRoute': actionRoute,
      'actionLabel': actionLabel,
      'imageUrl': imageUrl,
      'userId': userId,
      'isRead': isRead,
      'createdAt': timestamp.toUtc().toIso8601String(),
    };
  }

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
    String? targetGroup,
    String? imageUrl,
    String? userId,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
      targetGroup: targetGroup ?? this.targetGroup,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
    );
  }
}

// User Delivery Address Model
class UserAddress {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String phone;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'fullAddress': fullAddress,
    'city': city,
    'phone': phone,
    'isDefault': isDefault,
  };

  factory UserAddress.fromMap(Map<String, dynamic> map) {
    return UserAddress(
      id: _str(map['id']),
      label: _str(map['label'], 'Delivery Address'),
      fullAddress: _str(map['fullAddress']),
      city: _str(map['city']),
      phone: _str(map['phone']),
      isDefault: map['isDefault'] == true,
    );
  }

  UserAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? phone,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// User Registered Equipment / Gear Locker Model
class RegisteredGear {
  final String id;
  final String brand;
  final String model;
  final String serialNumber;
  final String warrantyStatus;
  final DateTime registeredAt;

  const RegisteredGear({
    required this.id,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.warrantyStatus,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'brand': brand,
    'model': model,
    'serialNumber': serialNumber,
    'warrantyStatus': warrantyStatus,
    'registeredAt': registeredAt.toUtc().toIso8601String(),
  };

  factory RegisteredGear.fromMap(Map<String, dynamic> map) {
    return RegisteredGear(
      id: _str(map['id']),
      brand: _str(map['brand']),
      model: _str(map['model']),
      serialNumber: _str(map['serialNumber']),
      warrantyStatus: _str(map['warrantyStatus'], 'Active Lab Warranty'),
      registeredAt: _asDate(map['registeredAt']) ?? DateTime.now(),
    );
  }

  RegisteredGear copyWith({
    String? id,
    String? brand,
    String? model,
    String? serialNumber,
    String? warrantyStatus,
    DateTime? registeredAt,
  }) {
    return RegisteredGear(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      warrantyStatus: warrantyStatus ?? this.warrantyStatus,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}


