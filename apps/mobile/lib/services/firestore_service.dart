import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get db => _db;

  User? get currentFirebaseUser => _auth.currentUser;

  // ----------------------------------------------------------------------
  // AUTHENTICATION & USER PROFILE
  // ----------------------------------------------------------------------

  Future<UserModel> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return UserModel(
        id: uid,
        name: data['name'] ?? email.split('@')[0],
        email: email.trim(),
        phone: data['phone'] ?? '',
        role: data['role'] ?? 'customer',
        technicianType: data['technicianType'],
        status: data['status'] ?? 'ACTIVE',
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      );
    } else {
      // Fallback: create user doc in Firestore if missing
      final newUser = UserModel(
        id: uid,
        name: cred.user?.displayName ?? email.split('@')[0],
        email: email.trim(),
        phone: cred.user?.phoneNumber ?? '',
        role: 'customer',
        status: 'ACTIVE',
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        'name': newUser.name,
        'email': newUser.email,
        'phone': newUser.phone,
        'role': newUser.role,
        'status': newUser.status,
        'createdAt': newUser.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return newUser;
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = cred.user!.uid;
    final now = DateTime.now();

    final user = UserModel(
      id: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: 'customer',
      status: 'ACTIVE',
      createdAt: now,
    );

    // Save profile to Firestore users and customers collections
    await _db.collection('users').doc(uid).set({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': 'customer',
      'status': 'ACTIVE',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    await _db.collection('customers').doc(uid).set({
      'userId': uid,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'createdAt': now.toIso8601String(),
    }, SetOptions(merge: true));

    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ----------------------------------------------------------------------
  // PRODUCTS & STORE
  // ----------------------------------------------------------------------

  Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<UsedProductModel>> streamUsedProducts() {
    return _db.collection('usedProducts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UsedProductModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  // ----------------------------------------------------------------------
  // SERVICE REQUESTS (REPAIRS)
  // ----------------------------------------------------------------------

  Future<String> createServiceRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String title,
    required String description,
    required String city,
    required String streetAddress,
    required String preferredDate,
    required String preferredTimeSlot,
    required String serviceType,
  }) async {
    final now = DateTime.now();
    final docRef = await _db.collection('serviceRequests').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'title': title,
      'description': description,
      'status': 'REQUESTED',
      'serviceType': serviceType,
      'address': {
        'city': city,
        'streetAddress': streetAddress,
      },
      'preferredSchedule': {
        'preferredDate': preferredDate,
        'preferredTimeSlot': preferredTimeSlot,
      },
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  Stream<List<ServiceRequestModel>> streamServiceRequests({String? customerId, String? technicianId}) {
    Query<Map<String, dynamic>> query = _db.collection('serviceRequests');
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    } else if (technicianId != null) {
      query = query.where('assignedTechnicianId', isEqualTo: technicianId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => ServiceRequestModel.fromFirestore(d.id, d.data()))
        .toList());
  }

  Stream<List<ServiceRequestModel>> streamCustomerRequests(String customerId) =>
      streamServiceRequests(customerId: customerId);

  Stream<List<ServiceRequestModel>> streamTechnicianJobs(String technicianId) =>
      streamServiceRequests(technicianId: technicianId);

  Stream<List<ServiceQuoteModel>> streamQuotes({String? customerId}) {
    Query<Map<String, dynamic>> query = _db.collection('quotes');
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => ServiceQuoteModel.fromFirestore(d.id, d.data()))
        .toList());
  }

  Stream<List<ServiceQuoteModel>> streamCustomerQuotes(String customerId) =>
      streamQuotes(customerId: customerId);

  Future<void> updateQuoteStatus(String quoteId, String status) async {
    await _db.collection('quotes').doc(quoteId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
      if (status == 'ACCEPTED') 'acceptedAt': DateTime.now().toIso8601String(),
      if (status == 'REJECTED') 'rejectedAt': DateTime.now().toIso8601String(),
    });
  }

  // ----------------------------------------------------------------------
  // ORDERS & SOURCING
  // ----------------------------------------------------------------------

  Future<String> createOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String city,
    required String streetAddress,
    required String paymentMethod,
    required int subtotal,
    required int deliveryFee,
    required int total,
    required List<CartItemModel> items,
  }) async {
    final now = DateTime.now();
    final docRef = await _db.collection('orders').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'city': city,
      'streetAddress': streetAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentMethod == 'COD' ? 'PENDING_COD' : 'PENDING_BANK_TRANSFER',
      'orderStatus': 'CONFIRMED',
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'items': items
          .map((i) => {
                'productId': i.productId,
                'name': i.name,
                'quantity': i.quantity,
                'unitPrice': i.unitPrice,
                'totalPrice': i.totalPrice,
                'productType': i.productType,
                'imageUrl': i.imageUrl,
              })
          .toList(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  Stream<List<OrderModel>> streamOrders({String? customerId}) {
    Query<Map<String, dynamic>> query = _db.collection('orders');
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => OrderModel.fromFirestore(d.id, d.data()))
        .toList());
  }

  Stream<List<OrderModel>> streamCustomerOrders(String customerId) =>
      streamOrders(customerId: customerId);

  Future<String> createSourceRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String itemName,
    required String budget,
    required String city,
    required String notes,
  }) async {
    final now = DateTime.now();
    final docRef = await _db.collection('sourceRequests').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'itemDescription': itemName,
      'budget': budget,
      'city': city,
      'notes': notes,
      'status': 'SUBMITTED',
      'advanceDeposit': 0,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  Stream<List<SourceRequestModel>> streamSourceRequests({String? customerId}) {
    Query<Map<String, dynamic>> query = _db.collection('sourceRequests');
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => SourceRequestModel.fromFirestore(d.id, d.data()))
        .toList());
  }

  Stream<List<SourceRequestModel>> streamCustomerSourceRequests(String customerId) =>
      streamSourceRequests(customerId: customerId);

  // ----------------------------------------------------------------------
  // CHAT / MESSAGING
  // ----------------------------------------------------------------------

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessageModel.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> sendChatMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final now = DateTime.now();

    await _db.collection('conversations').doc(conversationId).set({
      'participantIds': FieldValue.arrayUnion([senderId, 'admin', 'technician']),
      'lastMessage': text,
      'lastMessageAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    }, SetOptions(merge: true));

    await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'attachmentUrls': [],
      'createdAt': now.toIso8601String(),
    });
  }
}
