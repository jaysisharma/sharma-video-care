import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../firebase_options.dart';
import 'google_auth_service.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Ensures Firebase core is ready before performing operations.
  /// If Firebase was not ready during main() cold start, this initializes it on demand.
  Future<void> ensureInitialized() async {
    if (isFirebaseAvailable) return;
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } on FirebaseException catch (e) {
          if (e.code == 'duplicate-app') {
            Firebase.app();
          } else {
            rethrow;
          }
        }
      }
    } catch (_) {
      try {
        Firebase.app();
      } catch (_) {
        try {
          await Firebase.initializeApp();
        } catch (_) {}
      }
    }
  }

  bool get isFirebaseAvailable {
    if (Firebase.apps.isNotEmpty) return true;
    try {
      Firebase.app();
      return true;
    } catch (_) {
      try {
        FirebaseAuth.instance;
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  FirebaseFirestore get db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      try {
        Firebase.app();
        return FirebaseFirestore.instance;
      } catch (e) {
        throw StateError("Firebase Firestore unavailable: $e");
      }
    }
  }

  FirebaseAuth get auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      try {
        Firebase.app();
        return FirebaseAuth.instance;
      } catch (e) {
        throw StateError("Firebase Auth unavailable: $e");
      }
    }
  }

  FirebaseFirestore get _db => db;
  FirebaseAuth get _auth => auth;

  User? get currentFirebaseUser {
    if (!isFirebaseAvailable) return null;
    try {
      return auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Unguessable customer id for guest orders/requests ("guest-<32 hex chars>"),
  /// matching isGuestId() in firestore.rules.
  static String newGuestId() {
    final rand = Random.secure();
    final hex = List.generate(16, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return 'guest-$hex';
  }

  // ----------------------------------------------------------------------
  // AUTHENTICATION & USER PROFILE
  // ----------------------------------------------------------------------

  /// Authenticates only. The profile is loaded by AppState so there is a single
  /// place that reads it (and can fall back when Firestore is unreachable).
  Future<User> signIn({required String email, required String password}) async {
    await ensureInitialized();
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

  /// Writes the users/{uid} and customers/{uid} documents for a new customer.
  Future<UserModel> createCustomerProfile({
    required User user,
    required String name,
    required String email,
    required String phone,
  }) async {
    final now = DateTime.now();
    final profile = UserModel(
      id: user.uid,
      name: name,
      email: email,
      phone: phone,
      role: 'customer',
      status: 'ACTIVE',
      createdAt: now,
    );

    try {
      final docRef = _db.collection('users').doc(user.uid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({
          'name': profile.name,
          'email': profile.email,
          'phone': profile.phone,
          'role': 'customer',
          'status': 'ACTIVE',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
      } else {
        await docRef.set({
          'name': profile.name,
          'phone': profile.phone,
          'updatedAt': now.toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('User profile document notice: $e');
    }

    try {
      await _db.collection('customers').doc(user.uid).set({
        'userId': user.uid,
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'createdAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Customer profile document notice: $e');
    }

    return profile;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await ensureInitialized();
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
    } catch (e) {
      debugPrint('createCustomerProfile notice: $e');
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

    await _db.collection('users').doc(uid).set({
      'name': cleanName,
      'phone': cleanPhone,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await _db.collection('customers').doc(uid).set({
      'name': cleanName,
      'phone': cleanPhone,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

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
    await ensureInitialized();
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> resendVerificationEmail() async {
    await ensureInitialized();
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Deletes the profile documents and the Firebase Auth account (required by
  /// App Store guideline 5.1.1(v)). Orders and repair records are retained.
  /// Signs in with Google. A guest who used chat (anonymous) is upgraded in place so
  /// their support conversation is kept; if that Google account already exists, it
  /// simply signs in to it.
  Future<User> signInWithGoogle() async {
    await ensureInitialized();
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
    await ensureInitialized();
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
      default:
        final idToken = await GoogleAuthService.requestIdToken();
        await user.reauthenticateWithCredential(GoogleAuthProvider.credential(idToken: idToken));
    }

    try {
      await _db.collection('customers').doc(user.uid).delete();
    } catch (_) {}
    await _db.collection('users').doc(user.uid).delete();
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

  Stream<List<ProductModel>> streamProducts() {
    if (!isFirebaseAvailable) {
      return Stream.value(const <ProductModel>[]);
    }
    try {
      return _db.collection('products').snapshots().map((snapshot) {
        final list = <ProductModel>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(ProductModel.fromFirestore(doc.id, doc.data()));
          } catch (e) {
            debugPrint('Failed to parse product ${doc.id}: $e');
          }
        }
        return list;
      }).handleError((Object error) {
        debugPrint('Firestore streamProducts error: $error');
        return const <ProductModel>[];
      });
    } catch (e) {
      debugPrint('Firestore streamProducts init error: $e');
      return Stream.value(const <ProductModel>[]);
    }
  }

  Stream<List<UsedProductModel>> streamUsedProducts() {
    if (!isFirebaseAvailable) {
      return Stream.value(const <UsedProductModel>[]);
    }
    try {
      return _db.collection('usedProducts').snapshots().map((snapshot) {
        final list = <UsedProductModel>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(UsedProductModel.fromFirestore(doc.id, doc.data()));
          } catch (e) {
            debugPrint('Failed to parse used product ${doc.id}: $e');
          }
        }
        return list;
      }).handleError((Object error) {
        debugPrint('Firestore streamUsedProducts error: $error');
        return const <UsedProductModel>[];
      });
    } catch (e) {
      debugPrint('Firestore streamUsedProducts init error: $e');
      return Stream.value(const <UsedProductModel>[]);
    }
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
    final now = DateTime.now();
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

  Future<ServiceRequestModel?> getServiceRequest(String requestId) async {
    final doc = await _db.collection('serviceRequests').doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ServiceRequestModel.fromFirestore(doc.id, doc.data()!);
  }

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
    final now = DateTime.now();
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
  /// (the transition firestore.rules allows customers and guests to make).
  Future<void> submitPaymentProof({
    required String orderId,
    required String customerId,
    required int amount,
    required String referenceNumber,
    String? proofImageUrl,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _db.collection('payments').add({
      'orderId': orderId,
      'customerId': customerId,
      'method': 'BANK_TRANSFER',
      'amount': amount,
      'referenceNumber': referenceNumber.trim(),
      if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
      'status': 'PENDING_VERIFICATION',
      'submittedAt': now,
    });
    await _db.collection('orders').doc(orderId).update({
      'paymentStatus': 'PENDING_VERIFICATION',
      'orderStatus': 'PAYMENT_SUBMITTED',
      'updatedAt': now,
    });
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
    if (!isFirebaseAvailable) {
      return Stream.value(const <SourceRequestModel>[]);
    }
    try {
      Query<Map<String, dynamic>> query = _db.collection('sourceRequests');
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }
      return query.snapshots().map((snap) {
        final list = <SourceRequestModel>[];
        for (final d in snap.docs) {
          try {
            list.add(SourceRequestModel.fromFirestore(d.id, d.data()));
          } catch (e) {
            debugPrint('Failed to parse source request ${d.id}: $e');
          }
        }
        return list;
      }).handleError((Object error) {
        debugPrint('Firestore streamSourceRequests error: $error');
        return const <SourceRequestModel>[];
      });
    } catch (e) {
      debugPrint('Firestore streamSourceRequests init error: $e');
      return Stream.value(const <SourceRequestModel>[]);
    }
  }

  Stream<List<SourceRequestModel>> streamCustomerSourceRequests(String customerId) =>
      streamSourceRequests(customerId: customerId);

  // ----------------------------------------------------------------------
  // CHAT / MESSAGING
  // ----------------------------------------------------------------------

  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    if (!isFirebaseAvailable) {
      return Stream.value(const <ChatMessageModel>[]);
    }
    try {
      return _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snap) {
            final list = <ChatMessageModel>[];
            for (final d in snap.docs) {
              try {
                list.add(ChatMessageModel.fromFirestore(d.id, d.data()));
              } catch (e) {
                debugPrint('Failed to parse chat message ${d.id}: $e');
              }
            }
            return list;
          }).handleError((Object error) {
            debugPrint('Firestore streamMessages error: $error');
            return const <ChatMessageModel>[];
          });
    } catch (e) {
      debugPrint('Firestore streamMessages init error: $e');
      return Stream.value(const <ChatMessageModel>[]);
    }
  }

  Future<void> sendChatMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
    List<String> attachmentUrls = const [],
  }) async {
    final now = DateTime.now();

    final lastMessagePreview = text.isNotEmpty
        ? text
        : (attachmentUrls.isNotEmpty ? '📷 [Image attachment]' : '');

    await _db.collection('conversations').doc(conversationId).set({
      'participantIds': FieldValue.arrayUnion([senderId, 'admin', 'technician']),
      'lastMessage': lastMessagePreview,
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
      'attachmentUrls': attachmentUrls,
      'createdAt': now.toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------------
  // Notifications Collection
  // ---------------------------------------------------------------------------

  Stream<List<NotificationItemModel>> streamNotifications({
    String? userId,
    bool isGuest = false,
  }) {
    if (!isFirebaseAvailable) {
      return Stream.value(const <NotificationItemModel>[]);
    }
    try {
      return _db.collection('notifications').snapshots().map((snapshot) {
        final list = <NotificationItemModel>[];
        for (final d in snapshot.docs) {
          try {
            list.add(NotificationItemModel.fromFirestore(d.id, d.data()));
          } catch (e) {
            debugPrint('Failed to parse notification ${d.id}: $e');
          }
        }
        final filtered = list.where((n) {
          final target = n.targetGroup?.toLowerCase() ?? 'all';
          if (target == 'all') return true;
          if (isGuest) {
            return target == 'guest' || n.userId == 'guest';
          } else {
            return target == 'users' ||
                n.userId == 'users' ||
                (userId != null && n.userId == userId);
          }
        }).toList();

        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return filtered;
      }).handleError((Object error) {
        debugPrint('Firestore streamNotifications error: $error');
        return const <NotificationItemModel>[];
      });
    } catch (e) {
      debugPrint('Firestore streamNotifications init error: $e');
      return Stream.value(const <NotificationItemModel>[]);
    }
  }

  Future<void> markNotificationRead(String notificationId, {String? userId}) async {
    try {
      await _db.collection('notifications').doc(notificationId).set({
        'isRead': true,
        'read': true,
        if (userId != null) 'readBy': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

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
    final now = DateTime.now();
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
      'createdAt': now.toIso8601String(),
    });
    return docRef.id;
  }
}

