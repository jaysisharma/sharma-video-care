import 'package:flutter_test/flutter_test.dart';
import 'package:sharma_video_care_mobile/models/models.dart';

void main() {
  group('ProductModel Tests', () {
    test('ProductModel.fromFirestore parses full data correctly', () {
      final data = {
        'name': 'Canon EOS R5 C Cinema Camera',
        'brand': 'Canon',
        'categoryName': 'Cinema Cameras',
        'price': 525000,
        'availabilityType': 'IN_STOCK',
        'stockQuantity': 4,
        'description': 'Full-frame 8K cinema camera with internal active cooling.',
        'images': ['https://example.com/r5c-front.jpg', 'https://example.com/r5c-back.jpg'],
        'warrantyInfo': '2 Years Official Canon Warranty',
        'returnPolicyInfo': '7 Days Return Policy',
      };

      final product = ProductModel.fromFirestore('prod-r5c', data);

      expect(product.id, equals('prod-r5c'));
      expect(product.name, equals('Canon EOS R5 C Cinema Camera'));
      expect(product.brand, equals('Canon'));
      expect(product.categoryName, equals('Cinema Cameras'));
      expect(product.price, equals(525000));
      expect(product.availabilityType, equals('IN_STOCK'));
      expect(product.stockQuantity, equals(4));
      expect(product.imageUrl, equals('https://example.com/r5c-front.jpg'));
      expect(product.warrantyInfo, equals('2 Years Official Canon Warranty'));
      expect(product.returnPolicyInfo, equals('7 Days Return Policy'));
    });

    test('ProductModel.fromFirestore handles string numbers and empty images fallback', () {
      final data = {
        'name': 'Generic HDMI Cable',
        'price': '1500',
        'stockQuantity': '12',
        'images': <dynamic>[],
      };

      final product = ProductModel.fromFirestore('prod-hdmi', data);

      expect(product.id, equals('prod-hdmi'));
      expect(product.price, equals(1500));
      expect(product.stockQuantity, equals(12));
      expect(product.imageUrl, isNull);
      expect(product.brand, equals(''));
      expect(product.warrantyInfo, equals('Manufacturer Warranty'));
      expect(product.originalPrice, isNull);
      expect(product.hasDiscount, isFalse);
      expect(product.discountPercent, equals(0));
    });

    test('ProductModel discount comes only from a real originalPrice', () {
      final onSale = ProductModel.fromFirestore('p1', {'price': 320000, 'originalPrice': 385000});
      expect(onSale.hasDiscount, isTrue);
      expect(onSale.discountPercent, equals(17));

      final stringPrice = ProductModel.fromFirestore('p2', {'price': 900, 'originalPrice': '1000'});
      expect(stringPrice.discountPercent, equals(10));

      final notCheaper = ProductModel.fromFirestore('p3', {'price': 5000, 'originalPrice': 5000});
      expect(notCheaper.hasDiscount, isFalse);
      expect(notCheaper.discountPercent, equals(0));
    });

    test('ProductModel flash deal is live only while flagged, discounted, in stock and unexpired', () {
      final now = DateTime.utc(2026, 10, 26, 12);
      final live = ProductModel.fromFirestore('d', {
        'price': 320000,
        'originalPrice': 385000,
        'isFlashDeal': true,
        'flashDealEndsAt': '2026-10-29T12:00:00.000Z', // web admin writes ISO strings
      });
      expect(live.flashDealEndsAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 29, 12)), isTrue);
      expect(live.isLiveFlashDeal(now), isTrue);
      expect(live.isLiveFlashDeal(DateTime.utc(2026, 10, 29, 12, 0, 1)), isFalse);

      final unflagged = ProductModel.fromFirestore('d', {'price': 1, 'originalPrice': 2, 'flashDealEndsAt': '2026-10-29T12:00:00Z'});
      expect(unflagged.isLiveFlashDeal(now), isFalse);

      final noDiscount = ProductModel.fromFirestore('d', {'price': 2, 'originalPrice': 2, 'isFlashDeal': true, 'flashDealEndsAt': '2026-10-29T12:00:00Z'});
      expect(noDiscount.isLiveFlashDeal(now), isFalse);

      final soldOut = ProductModel.fromFirestore('d', {
        'price': 1, 'originalPrice': 2, 'isFlashDeal': true,
        'flashDealEndsAt': '2026-10-29T12:00:00Z', 'availabilityType': 'OUT_OF_STOCK',
      });
      expect(soldOut.isLiveFlashDeal(now), isFalse);

      final noEnd = ProductModel.fromFirestore('d', {'price': 1, 'originalPrice': 2, 'isFlashDeal': true});
      expect(noEnd.isLiveFlashDeal(now), isFalse);
    });

    test('ProductModel.isOutOfStock follows availabilityType', () {
      expect(ProductModel.fromFirestore('p', {'availabilityType': 'OUT_OF_STOCK'}).isOutOfStock, isTrue);
      expect(ProductModel.fromFirestore('p', {'availabilityType': 'IN_STOCK'}).isOutOfStock, isFalse);
    });
  });

  group('OrderModel Tests', () {
    test('OrderModel.fromFirestore correctly summarizes items and parses addresses', () {
      final data = {
        'customerId': 'cust-101',
        'total': 48000,
        'paymentMethod': 'COD',
        'paymentStatus': 'PAID',
        'orderStatus': 'SHIPPED',
        'items': [
          {'name': 'Sony NP-FZ100 Battery', 'quantity': 2},
          {'name': 'SanDisk CFexpress 128GB', 'quantity': 1},
        ],
        'shippingAddress': {
          'city': 'Kathmandu',
          'streetAddress': 'Thamel Marg, Ward 26',
        },
        'courierDetails': {
          'partnerName': 'Nepal Can Move',
          'trackingNumber': 'NCM-892347',
        },
        'createdAt': '2026-10-18T10:30:00.000Z',
      };

      final order = OrderModel.fromFirestore('order-101', data);

      expect(order.id, equals('order-101'));
      expect(order.customerId, equals('cust-101'));
      expect(order.total, equals(48000));
      expect(order.paymentMethod, equals('COD'));
      expect(order.paymentStatus, equals('PAID'));
      expect(order.orderStatus, equals('SHIPPED'));
      expect(order.city, equals('Kathmandu'));
      expect(order.streetAddress, equals('Thamel Marg, Ward 26'));
      expect(order.itemsSummary, equals('Sony NP-FZ100 Battery (x2), SanDisk CFexpress 128GB (x1)'));
      expect(order.courierPartner, equals('Nepal Can Move'));
      expect(order.trackingNumber, equals('NCM-892347'));
      expect(order.createdAt.year, equals(2026));
    });

    test('OrderModel.fromFirestore handles string total and fallback values', () {
      final data = {
        'total': '12000',
        'shippingAddress': null,
        'courierDetails': null,
        'items': null,
      };

      final order = OrderModel.fromFirestore('order-fallback', data);

      expect(order.id, equals('order-fallback'));
      expect(order.total, equals(12000));
      expect(order.city, equals('Janakpur'));
      expect(order.streetAddress, equals(''));
      expect(order.itemsSummary, equals(''));
      expect(order.courierPartner, isNull);
      expect(order.trackingNumber, isNull);
      expect(order.orderStatus, equals('PENDING_PAYMENT')); // missing status is never shown as confirmed
    });
  });

  group('ServiceRequestModel and ServiceQuoteModel Tests', () {
    test('ServiceRequestModel.fromFirestore parses nested schedule and address', () {
      final data = {
        'customerId': 'cust-202',
        'customerName': 'Aarav Sharma',
        'customerPhone': '+977 9801234567',
        'title': 'Sony FX3 Sensor Cleaning & Lens Mount Realignment',
        'description': 'Camera dropped from tripod, front mount is misaligned.',
        'status': 'DIAGNOSED',
        'address': {
          'city': 'Janakpurdham',
          'streetAddress': 'Station Road, Shop #4',
        },
        'preferredSchedule': {
          'preferredDate': '2026-10-25',
          'preferredTimeSlot': 'Afternoon (1 PM - 4 PM)',
        },
        'assignedTechnicianId': 'tech-rajesh',
        'assignedTechnicianName': 'Rajesh Kumar',
        'quoteId': 'quote-505',
        'createdAt': '2026-10-15T08:00:00.000Z',
      };

      final req = ServiceRequestModel.fromFirestore('srv-1', data);

      expect(req.id, equals('srv-1'));
      expect(req.customerName, equals('Aarav Sharma'));
      expect(req.city, equals('Janakpurdham'));
      expect(req.streetAddress, equals('Station Road, Shop #4'));
      expect(req.preferredDate, equals('2026-10-25'));
      expect(req.preferredTimeSlot, equals('Afternoon (1 PM - 4 PM)'));
      expect(req.assignedTechnicianName, equals('Rajesh Kumar'));
      expect(req.quoteId, equals('quote-505'));
    });

    test('ServiceQuoteModel.fromFirestore parses monetary values and status', () {
      final data = {
        'serviceRequestId': 'srv-1',
        'labourTotal': 3500,
        'partsTotal': 12000,
        'total': 15500,
        'status': 'SENT',
        'warrantyTerms': '90 Days Service Warranty on Mount Alignment',
        'notes': 'Replaced front bayonet flange and optical alignment shims.',
      };

      final quote = ServiceQuoteModel.fromFirestore('quote-505', data);

      expect(quote.id, equals('quote-505'));
      expect(quote.serviceRequestId, equals('srv-1'));
      expect(quote.labourTotal, equals(3500));
      expect(quote.partsTotal, equals(12000));
      expect(quote.total, equals(15500));
      expect(quote.status, equals('SENT'));
      expect(quote.warrantyTerms, equals('90 Days Service Warranty on Mount Alignment'));
      expect(quote.notes, contains('bayonet flange'));
    });
  });

  group('SourceRequestModel Tests', () {
    test('SourceRequestModel.fromFirestore parses correctly', () {
      final data = {
        'customerId': 'cust-303',
        'itemDescription': 'Sony FE 70-200mm F2.8 GM OSS II',
        'budget': 'Rs. 320,000 - 340,000',
        'city': 'Janakpur',
        'status': 'SOURCING',
        'notes': 'Prefer mint condition with original lens hood and collar.',
        'advanceDeposit': 0,
        'createdAt': '2026-10-17T14:00:00.000Z',
      };

      final src = SourceRequestModel.fromFirestore('src-101', data);

      expect(src.id, equals('src-101'));
      expect(src.customerId, equals('cust-303'));
      expect(src.itemDescription, equals('Sony FE 70-200mm F2.8 GM OSS II'));
      expect(src.budget, equals('Rs. 320,000 - 340,000'));
      expect(src.city, equals('Janakpur'));
      expect(src.status, equals('SOURCING'));
      expect(src.advanceDeposit, equals(0));
      expect(src.notes, contains('mint condition'));
    });
  });

  group('NotificationItemModel Tests', () {
    test('NotificationItemModel copyWith updates specified fields only', () {
      final now = DateTime.now();
      final original = NotificationItemModel(
        id: 'notif-1',
        title: 'Order Dispatched',
        message: 'Your shipment is on its way.',
        category: 'orders',
        timestamp: now,
        isRead: false,
        actionRoute: 'shop',
        actionLabel: 'Track Shipment',
      );

      final updated = original.copyWith(isRead: true);

      expect(updated.id, equals(original.id));
      expect(updated.title, equals(original.title));
      expect(updated.message, equals(original.message));
      expect(updated.category, equals(original.category));
      expect(updated.timestamp, equals(now));
      expect(updated.isRead, isTrue);
      expect(updated.actionRoute, equals('shop'));
      expect(updated.actionLabel, equals('Track Shipment'));
    });
  });

  group('CartItemModel Tests', () {
    test('CartItemModel calculates totalPrice correctly', () {
      final item = CartItemModel(
        productId: 'prod-mic',
        productType: 'NEW',
        name: 'Rode Wireless PRO Microphone System',
        unitPrice: 58000,
        quantity: 2,
      );

      expect(item.totalPrice, equals(116000));

      item.quantity = 4;
      expect(item.totalPrice, equals(232000));
    });
  });

  group('NotificationItemModel read state', () {
    test('a broadcast is read only for viewers listed in readBy', () {
      final data = {'title': 'Sale', 'targetGroup': 'all', 'isRead': true, 'readBy': ['u1']};
      expect(NotificationItemModel.fromFirestore('n1', data, viewerId: 'u1').isRead, isTrue);
      expect(NotificationItemModel.fromFirestore('n1', data, viewerId: 'u2').isRead, isFalse);
      expect(NotificationItemModel.fromFirestore('n1', data).isRead, isFalse); // guest
    });

    test('a personal notification still honours the legacy isRead flag', () {
      final data = {'title': 'Order shipped', 'targetGroup': 'specific', 'userId': 'u1', 'isRead': true};
      expect(NotificationItemModel.fromFirestore('n2', data, viewerId: 'u1').isRead, isTrue);
    });
  });

  group('Dates', () {
    test('UTC strings from the website are read as local time', () {
      final order = OrderModel.fromFirestore('o1', {'createdAt': '2026-10-01T15:00:00Z', 'items': []});
      expect(order.createdAt.isUtc, isFalse);
      expect(order.createdAt.isAtSameMomentAs(DateTime.utc(2026, 10, 1, 15)), isTrue);
    });

    test('dates are written as UTC', () {
      final n = NotificationItemModel(id: 'n', title: 't', message: 'm', category: 'system', timestamp: DateTime(2026, 10, 1, 20, 45));
      expect(n.toMap()['createdAt'], endsWith('Z'));
    });
  });

  group('Website-created and loosely typed data', () {
    test('a source request from the website (numeric budget, no deposit) parses', () {
      final r = SourceRequestModel.fromFirestore('s1', {'itemDescription': 'Sony FX3', 'budget': 450000, 'customerId': 'u1'});
      expect(r.budget, '450000');
      expect(r.advanceDeposit, 0);
      expect(SourceRequestModel.fromFirestore('s2', {'advanceDeposit': 1500.0}).advanceDeposit, 1500);
    });

    test('non-text values in text fields are shown as text', () {
      final u = UserModel.fromFirestore('u1', {'name': 'Ram', 'phone': 9801234567, 'role': 'technician'});
      expect(u.phone, '9801234567');
      expect(u.role, 'technician');
    });
  });

  group('CartItemModel persistence', () {
    test('round-trips through toMap/fromMap', () {
      final item = CartItemModel(productId: 'p1', productType: 'USED', name: 'A7 III', unitPrice: 155000, quantity: 2, imageUrl: 'https://x/y.jpg');
      final copy = CartItemModel.fromMap(item.toMap());
      expect([copy.productId, copy.productType, copy.name, copy.unitPrice, copy.quantity, copy.imageUrl],
          ['p1', 'USED', 'A7 III', 155000, 2, 'https://x/y.jpg']);
    });
  });
}
