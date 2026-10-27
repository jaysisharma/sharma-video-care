import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/models.dart';
import 'google_auth_service.dart';

/// Current time as a UTC ISO-8601 string ("...Z"), the same format the website
/// writes, so string ordering and parsing agree across app, web and admin.
String nowIsoUtc() => DateTime.now().toUtc().toIso8601String();

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// main() only starts the app once Firebase is up; this is false in tests.
  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  FirebaseFirestore get db => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  FirebaseFirestore get _db => db;
  FirebaseAuth get _auth => auth;

  User? get currentFirebaseUser => isFirebaseAvailable ? _auth.currentUser : null;

  /// Unguessable customer id for guest orders/requests ("guest-<32 hex chars>"),
  /// matching isGuestId() in firestore.rules.
  static String newGuestId() {
    final rand = Random.secure();
    final hex = List.generate(16, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return 'guest-$hex';
  }

  /// Parses each document on its own so one malformed record is skipped (and
  /// reported) instead of failing the whole list.
  static List<T> _parseDocs<T>(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    T Function(String id, Map<String, dynamic> data) parse,
    String label, {
    bool Function(Map<String, dynamic> data)? include,
  }) {
    final list = <T>[];
    for (final doc in docs) {
      final data = doc.data();
      if (include != null && !include(data)) continue;
      try {
        list.add(parse(doc.id, data));
      } catch (e, stack) {
        debugPrint('Failed to parse $label ${doc.id}: $e');
        _report(e, stack, 'Parse $label ${doc.id}');
      }
    }
    return list;
  }

  /// Passes stream errors through to the screen (which shows its error state)
  /// and reports them, instead of swallowing them and leaving screens loading forever.
  static Stream<T> _reportErrors<T>(Stream<T> stream, String label) {
    return stream.transform(StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stack, sink) {
        debugPrint('Firestore $label error: $error');
        _report(error, stack, 'Firestore $label');
        sink.addError(error, stack);
      },
    ));
  }

  static void _report(Object error, StackTrace stack, String reason) {
    if (Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  }

  // ----------------------------------------------------------------------
  // AUTHENTICATION & USER PROFILE
  // ----------------------------------------------------------------------

  /// Authenticates only. The profile is loaded by AppState so there is a single
  /// place that reads it (and can fall back when Firestore is unreachable).
  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  /// "+977-98XXXXXXXX" for any Nepal mobile input ("98...", "+977 98...", "977-98...").
  static String normalizeNepalPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('977') && digits.length > 10) digits = digits.substring(3);
    return digits.isEmpty ? '' : '+977-$digits';
  }

  static bool isValidNepalMobile(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('977') && digits.length > 10) digits = digits.substring(3);
    return RegExp(r'^9[678]\d{8}$').hasMatch(digits);
  }

  /// Writes the users/{uid} and customers/{uid} documents for a new customer, in
  /// one batch. Throws if they can't be written; AppState creates any missing
  /// profile again on the next sign-in.
  Future<UserModel> createCustomerProfile({
    required User user,
    required String name,
    required String email,
    required String phone,
  }) async {
    final now = DateTime.now();
    final nowIso = now.toUtc().toIso8601String();
    final profile = UserModel(
      id: user.uid,
      name: name,
      email: email,
      phone: phone,
      role: 'customer',
      status: 'ACTIVE',
      createdAt: now,
    );

    final userRef = _db.collection('users').doc(user.uid);
    final userExists = (await userRef.get()).exists;
    final batch = _db.batch();
    if (!userExists) {
      batch.set(userRef, {
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'role': 'customer',
        'status': 'ACTIVE',
        'createdAt': nowIso,
        'updatedAt': nowIso,
      });
    } else {
      batch.set(userRef, {
        'name': profile.name,
        'phone': profile.phone,
        'updatedAt': nowIso,
      }, SetOptions(merge: true));
    }
    batch.set(_db.collection('customers').doc(user.uid), {
      'userId': user.uid,
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'createdAt': nowIso,
    }, SetOptions(merge: true));
    await batch.commit();

    return profile;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final credential = EmailAuthProvider.credential(email: cleanEmail, password: password);

    // A guest who used chat is signed in anonymously; upgrading that account keeps
    // their uid, so their support conversation carries over to the new account.
    final current = _auth.currentUser;
    UserCredential cred;
    if (current != null && current.isAnonymous) {
      try {
        cred = await current.linkWithCredential(credential);
      } catch (linkError) {
        debugPrint('Anonymous account linking failed: $linkError, creating fresh user');
        cred = await _auth.createUserWithEmailAndPassword(email: cleanEmail, password: password);
      }
    } else {
      cred = await _auth.createUserWithEmailAndPassword(email: cleanEmail, password: password);
    }
    final user = cred.user!;

    try {
      await user.updateDisplayName(cleanName);
    } catch (_) {}

    try {
      await user.sendEmailVerification();
    } catch (_) {}

    try {
      return await createCustomerProfile(
        user: user,
        name: cleanName,
        email: cleanEmail,
        phone: normalizeNepalPhone(phone),
      );
    } catch (e, stack) {
      // The account exists; the profile is created again on the next sign-in.
      debugPrint('createCustomerProfile failed: $e');
      _report(e, stack, 'Create customer profile');
      return UserModel(
        id: user.uid,
        name: cleanName,
        email: cleanEmail,
        phone: normalizeNepalPhone(phone),
        role: 'customer',
        status: 'ACTIVE',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = isValidNepalMobile(phone) ? normalizeNepalPhone(phone) : phone.trim();
    final nowIso = nowIsoUtc();

    final batch = _db.batch()
      ..set(_db.collection('users').doc(uid), {
        'name': cleanName,
        'phone': cleanPhone,
        'updatedAt': nowIso,
      }, SetOptions(merge: true))
      ..set(_db.collection('customers').doc(uid), {
        'name': cleanName,
        'phone': cleanPhone,
        'updatedAt': nowIso,
      }, SetOptions(merge: true));
    await batch.commit();

    try {
      await _auth.currentUser?.updateDisplayName(cleanName);
    } catch (_) {}
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No active authenticated user session found.');
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Signs in with Google. A guest who used chat (anonymous) is upgraded in place so
  /// their support conversation is kept; if that Google account already exists, it
  /// simply signs in to it.
  Future<User> signInWithGoogle() async {
    final idToken = await GoogleAuthService.requestIdToken();
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        return (await current.linkWithCredential(credential)).user!;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use') rethrow;
      }
    }
    return (await _auth.signInWithCredential(credential)).user!;
  }

  /// Signs in with Apple (iOS). Like Google, an anonymous guest is upgraded in place.
  Future<User> signInWithApple() async {
    final provider = AppleAuthProvider()..addScope('email')..addScope('name');
    final current = _auth.currentUser;
    UserCredential cred;
    if (current != null && current.isAnonymous) {
      try {
        cred = await current.linkWithProvider(provider);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use') rethrow;
        cred = await _auth.signInWithProvider(provider);
      }
    } else {
      cred = await _auth.signInWithProvider(provider);
    }
    final user = cred.user!;
    // Apple shares the name only on the very first sign-in.
    final name = [cred.additionalUserInfo?.profile?['firstName'], cred.additionalUserInfo?.profile?['lastName']]
        .whereType<String>()
        .join(' ')
        .trim();
    if ((user.displayName ?? '').isEmpty && name.isNotEmpty) {
      try {
        await user.updateDisplayName(name);
      } catch (_) {}
    }
    return user;
  }

  String? _primaryProvider(User user) {
    final ids = user.providerData.map((p) => p.providerId).toSet();
    if (ids.contains(EmailAuthProvider.PROVIDER_ID)) return EmailAuthProvider.PROVIDER_ID;
    if (ids.contains('apple.com')) return 'apple.com';
    if (ids.contains(GoogleAuthProvider.PROVIDER_ID)) return GoogleAuthProvider.PROVIDER_ID;
    return null;
  }

  /// True when the account can sign in with a password (false for Google-only accounts).
  bool get hasPasswordSignIn =>
      _auth.currentUser?.providerData.any((p) => p.providerId == EmailAuthProvider.PROVIDER_ID) ?? false;

  /// Deletes the profile documents and the Firebase Auth account (required by
  /// App Store guideline 5.1.1(v)). Orders and repair records are retained.
  /// Password accounts confirm with [currentPassword]; Google and Apple accounts
  /// confirm by signing in with that provider again. Apple tokens are revoked,
  /// as Apple requires when an account is deleted.
  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No active authenticated user session found.');
    }

    switch (_primaryProvider(user)) {
      case 'password': // EmailAuthProvider.PROVIDER_ID
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: currentPassword ?? ''),
        );
      case 'apple.com':
        final cred = await user.reauthenticateWithProvider(AppleAuthProvider());
        final authCode = cred.additionalUserInfo?.authorizationCode;
        if (authCode != null) {
          try {
            await _auth.revokeTokenWithAuthorizationCode(authCode);
          } catch (_) {}
        }
      case 'google.com': // GoogleAuthProvider.PROVIDER_ID
        final idToken = await GoogleAuthService.requestIdToken();
        await user.reauthenticateWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      default:
        throw FirebaseAuthException(
          code: 'unsupported-provider',
          message: 'This account type cannot be deleted from the app. Please contact support.',
        );
    }

    // Profile docs go first: the rules need the signed-in user to delete them.
    // The fresh re-authentication above makes the final user.delete() reliable.
    final batch = _db.batch()
      ..delete(_db.collection('customers').doc(user.uid))
      ..delete(_db.collection('users').doc(user.uid));
    await batch.commit();
    await user.delete();
    await GoogleAuthService.signOut();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleAuthService.signOut();
  }

  // ----------------------------------------------------------------------
  // PRODUCTS & STORE
  // ----------------------------------------------------------------------

  /// Products the admin has switched off (`active: false`) are left out.
  static bool _isActive(Map<String, dynamic> data) => data['active'] != false;

  Stream<List<ProductModel>> streamProducts() {
    return _reportErrors(
      _db.collection('products').snapshots().map((snap) =>
          _parseDocs(snap.docs, ProductModel.fromFirestore, 'product', include: _isActive)),
      'products',
    );
  }

  Stream<List<UsedProductModel>> streamUsedProducts() {
    return _reportErrors(
      _db.collection('usedProducts').snapshots().map((snap) =>
          _parseDocs(snap.docs, UsedProductModel.fromFirestore, 'used product', include: _isActive)),
      'usedProducts',
    );
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
    List<String> photoUrls = const [],
    String? photoUrl,
  }) async {
    final nowIso = nowIsoUtc();
    final allPhotos = [
      if (photoUrl != null && photoUrl.isNotEmpty) photoUrl,
      ...photoUrls,
    ];

    final docRef = await _db.collection('serviceRequests').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'title': title,
      'description': description,
      'status': 'REQUESTED',
      'serviceType': serviceType,
      'photoUrls': allPhotos,
      'evidenceUrl': allPhotos.isNotEmpty ? allPhotos.first : null,
      'address': {
        'city': city,
        'streetAddress': streetAddress,
      },
      'preferredSchedule': {
        'preferredDate': preferredDate,
        'preferredTimeSlot': preferredTimeSlot,
      },
      'createdAt': nowIso,
      'updatedAt': nowIso,
    });

    return docRef.id;
  }

  /// Repairs for one customer or one technician. Exactly one id is required: the
  /// rules only allow listing your own records, so an unfiltered query is denied.
  Stream<List<ServiceRequestModel>> streamServiceRequests({String? customerId, String? technicianId}) {
    if ((customerId == null) == (technicianId == null)) {
      throw ArgumentError('Pass exactly one of customerId or technicianId');
    }
    final query = customerId != null
        ? _db.collection('serviceRequests').where('customerId', isEqualTo: customerId)
        : _db.collection('serviceRequests').where('assignedTechnicianId', isEqualTo: technicianId);
    return _reportErrors(
      query.snapshots().map((snap) => _parseDocs(snap.docs, ServiceRequestModel.fromFirestore, 'service request')),
      'serviceRequests',
    );
  }

  Stream<List<ServiceRequestModel>> streamCustomerRequests(String customerId) =>
      streamServiceRequests(customerId: customerId);

  Stream<List<ServiceRequestModel>> streamTechnicianJobs(String technicianId) =>
      streamServiceRequests(technicianId: technicianId);

  Future<ServiceRequestModel?> getServiceRequest(String requestId) async {
    final doc = await _db.collection('serviceRequests').doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ServiceRequestModel.fromFirestore(doc.id, doc.data()!);
  }

  Stream<List<ServiceQuoteModel>> streamQuotes({required String customerId}) {
    return _reportErrors(
      _db
          .collection('quotes')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snap) => _parseDocs(snap.docs, ServiceQuoteModel.fromFirestore, 'quote')),
      'quotes',
    );
  }

  Stream<List<ServiceQuoteModel>> streamCustomerQuotes(String customerId) =>
      streamQuotes(customerId: customerId);

  Future<void> updateQuoteStatus(String quoteId, String status) async {
    final nowIso = nowIsoUtc();
    await _db.collection('quotes').doc(quoteId).update({
      'status': status,
      'updatedAt': nowIso,
      if (status == 'ACCEPTED') 'acceptedAt': nowIso,
      if (status == 'REJECTED') 'rejectedAt': nowIso,
    });
  }

  // ----------------------------------------------------------------------
  // ORDERS & SOURCING
  // ----------------------------------------------------------------------

  /// Creates an order in the same shape as the website (packages/shared OrderRecord),
  /// so the admin console and the onOrderCreated price check read it correctly.
  Future<String> createOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String city,
    required String streetAddress,
    String wardNumber = '',
    String landmarks = '',
    required String paymentMethod,
    required int subtotal,
    required int deliveryFee,
    required int total,
    required List<CartItemModel> items,
  }) async {
    final now = DateTime.now().toUtc();
    final docRef = await _db.collection('orders').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items
          .map((i) => {
                'productId': i.productId,
                'productType': i.productType,
                'name': i.name,
                if (i.imageUrl != null) 'image': i.imageUrl,
                'unitPrice': i.unitPrice,
                'quantity': i.quantity,
                'totalPrice': i.totalPrice,
              })
          .toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': 0,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'PENDING',
      'orderStatus': 'PENDING_PAYMENT',
      'shippingAddress': {
        'id': 'addr-${now.millisecondsSinceEpoch}',
        'label': 'Shipping Address',
        'recipientName': customerName,
        'phoneNumber': customerPhone,
        'province': '',
        'city': city,
        'wardNumber': wardNumber,
        'streetAddress': streetAddress,
        'landmarks': landmarks,
      },
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    return docRef.id;
  }

  /// Bank details shown for bank-transfer orders, from Firestore `settings/payment`
  /// ({bankName, accountName, accountNumber, branch}). Null until the shop fills it in.
  Future<Map<String, String>?> getPaymentSettings() async {
    try {
      final doc = await _db.collection('settings').doc('payment').get();
      final data = doc.data();
      if (data == null || (data['accountNumber'] ?? '').toString().trim().isEmpty) return null;
      return data.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return null;
    }
  }

  /// Records a bank-transfer payment for review and marks the order as submitted
  /// (the transition firestore.rules allows customers and guests to make). Both
  /// writes go in one batch so a retry can't leave a payment without its order update.
  Future<void> submitPaymentProof({
    required String orderId,
    required String customerId,
    required int amount,
    required String referenceNumber,
    String? proofImageUrl,
  }) async {
    final nowIso = nowIsoUtc();
    final batch = _db.batch()
      ..set(_db.collection('payments').doc(), {
        'orderId': orderId,
        'customerId': customerId,
        'method': 'BANK_TRANSFER',
        'amount': amount,
        'referenceNumber': referenceNumber.trim(),
        if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
        'status': 'PENDING_VERIFICATION',
        'submittedAt': nowIso,
      })
      ..update(_db.collection('orders').doc(orderId), {
        'paymentStatus': 'PENDING_VERIFICATION',
        'orderStatus': 'PAYMENT_SUBMITTED',
        'updatedAt': nowIso,
      });
    await batch.commit();
  }

  Stream<List<OrderModel>> streamOrders({required String customerId}) {
    return _reportErrors(
      _db
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snap) => _parseDocs(snap.docs, OrderModel.fromFirestore, 'order')),
      'orders',
    );
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
    final nowIso = nowIsoUtc();
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
      'createdAt': nowIso,
      'updatedAt': nowIso,
    });

    return docRef.id;
  }

  Stream<List<SourceRequestModel>> streamSourceRequests({required String customerId}) {
    return _reportErrors(
      _db
          .collection('sourceRequests')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snap) => _parseDocs(snap.docs, SourceRequestModel.fromFirestore, 'source request')),
      'sourceRequests',
    );
  }

  Stream<List<SourceRequestModel>> streamCustomerSourceRequests(String customerId) =>
      streamSourceRequests(customerId: customerId);

  // ----------------------------------------------------------------------
  // CHAT / MESSAGING
  // ----------------------------------------------------------------------

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    return _reportErrors(
      _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) => _parseDocs(snap.docs, ChatMessageModel.fromFirestore, 'chat message')),
      'messages',
    );
  }

  /// Updates the conversation and adds the message in one batch (the message rule
  /// checks the conversation as it will be after the write).
  Future<void> sendChatMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
    List<String> attachmentUrls = const [],
  }) async {
    final nowIso = nowIsoUtc();

    final lastMessagePreview = text.isNotEmpty
        ? text
        : (attachmentUrls.isNotEmpty ? '📷 [Image attachment]' : '');

    final conversation = _db.collection('conversations').doc(conversationId);
    final batch = _db.batch()
      ..set(conversation, {
        'participantIds': FieldValue.arrayUnion([senderId, 'admin', 'technician']),
        'lastMessage': lastMessagePreview,
        'lastMessageAt': nowIso,
        'updatedAt': nowIso,
      }, SetOptions(merge: true))
      ..set(conversation.collection('messages').doc(), {
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        'attachmentUrls': attachmentUrls,
        'createdAt': nowIso,
      });
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Notifications Collection
  // ---------------------------------------------------------------------------

  /// Notifications this viewer may read. The query mirrors the read rule in
  /// firestore.rules (rules don't filter: an unfiltered query is denied outright).
  /// Plain equality filters so the rules can check every branch.
  Stream<List<NotificationItemModel>> streamNotifications({
    String? userId,
    bool isGuest = false,
  }) {
    final audience = isGuest ? 'guest' : 'users';
    final filter = Filter.or(
      Filter('targetGroup', isEqualTo: 'all'),
      Filter('userId', isEqualTo: 'all'),
      Filter('targetGroup', isEqualTo: audience),
      Filter('userId', isEqualTo: audience),
      !isGuest && userId != null ? Filter('userId', isEqualTo: userId) : null,
    );
    return _reportErrors(
      _db.collection('notifications').where(filter).snapshots().map((snap) {
        final list = _parseDocs(
          snap.docs,
          (id, data) => NotificationItemModel.fromFirestore(id, data, viewerId: isGuest ? null : userId),
          'notification',
        );
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      }),
      'notifications',
    );
  }

  /// Adds [userId] to (or removes it from) `readBy` on each notification. Only
  /// `readBy` is written, so a shared broadcast isn't marked read for everyone.
  /// Guests aren't signed in and can't write; AppState keeps their read state on
  /// the device. Errors are reported, not thrown: read state is best effort.
  Future<void> setNotificationsRead(Iterable<String> ids, {required String userId, required bool read}) async {
    final list = ids.toList();
    final change = read ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]);
    try {
      for (var i = 0; i < list.length; i += 450) { // batches are capped at 500 writes
        final batch = _db.batch();
        for (final id in list.skip(i).take(450)) {
          batch.update(_db.collection('notifications').doc(id), {'readBy': change});
        }
        await batch.commit();
      }
    } catch (e, stack) {
      debugPrint('Error updating notification read state: $e');
      _report(e, stack, 'Notification read state');
    }
  }

  /// Admin only (firestore.rules); fails for customers.
  Future<String> createNotification({
    required String title,
    required String message,
    required String category,
    String targetGroup = 'all',
    String? userId,
    String? actionRoute,
    String? actionLabel,
    String? imageUrl,
  }) async {
    final docRef = await _db.collection('notifications').add({
      'title': title,
      'message': message,
      'category': category,
      'targetGroup': targetGroup,
      'userId': userId ?? targetGroup,
      'actionRoute': actionRoute,
      'actionLabel': actionLabel,
      'imageUrl': imageUrl,
      'isRead': false,
      'createdAt': nowIsoUtc(),
    });
    return docRef.id;
  }
}
