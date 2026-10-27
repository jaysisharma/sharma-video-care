import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  static const String _kIsLoggedIn = 'svc_is_logged_in';
  static const String _kUserId = 'svc_user_id';
  // Legacy keys that cached name/email/phone in plain SharedPreferences; now removed on load.
  static const List<String> _kLegacyPiiKeys = ['svc_user_name', 'svc_user_email', 'svc_user_phone'];
  static const String _kUserRole = 'svc_user_role';
  static const String _kUserTechType = 'svc_user_tech_type';
  static const String _kSelectedDeliveryHub = 'svc_selected_delivery_hub';
  // Cart contents (product ids, names, prices; no personal data). Cleared on sign-out.
  static const String _kCart = 'svc_cart';
  // Notification ids the viewer removed, per audience ('guest' or a uid), and a
  // guest's read ids (signed-in read state lives in Firestore `readBy`).
  static const String _kHiddenNotificationsPrefix = 'svc_notif_hidden_';
  static const String _kGuestReadNotifications = 'svc_notif_read_guest';

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isSessionLoaded = false;
  // True while signIn/signUp run; they load the profile themselves, so the auth
  // listener must not race them with a fallback profile write.
  bool _authInFlight = false;
  Future<void>? _sessionReconcile;
  // Profile syncs in progress by uid, so the auth listener's first event and
  // loadSession's background sync share one profile read instead of racing.
  final Map<String, Future<void>> _syncsInFlight = {};
  static const Duration _profileTimeout = Duration(seconds: 6);
  final List<CartItemModel> _cartItems = [];
  String _selectedDeliveryHub = 'Janakpur Hub';
  List<UserAddress> _savedAddresses = [];
  List<RegisteredGear> _registeredGear = [];

  // Notifications: server ones for the current audience plus ones the app adds
  // locally (e.g. "order placed"). Removal is per device; read state is per user.
  List<NotificationItemModel> _remoteNotifications = [];
  final List<NotificationItemModel> _localNotifications = [];
  Set<String> _hiddenNotificationIds = {};
  final Map<String, bool> _readOverrides = {};
  StreamSubscription<List<NotificationItemModel>>? _notificationSub;
  String? _notificationAudience;
  bool _notificationsLoading = false;
  Object? _notificationsError;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
  bool get isSessionLoaded => _isSessionLoaded;
  String get role => _currentUser?.role ?? 'customer';
  String? get technicianType => _currentUser?.technicianType;
  String get selectedDeliveryHub => _selectedDeliveryHub;

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.fold(0, (acc, item) => acc + item.quantity);
  int get cartSubtotal =>
      _cartItems.fold(0, (acc, item) => acc + item.totalPrice);
  int get deliveryFee => _cartItems.isNotEmpty ? 150 : 0;
  int get cartTotal => cartSubtotal + deliveryFee;

  int getItemQuantity(String productId) {
    final idx = _cartItems.indexWhere((i) => i.productId == productId);
    return idx != -1 ? _cartItems[idx].quantity : 0;
  }

  /// Newest first, without removed ones, with this viewer's read state applied.
  List<NotificationItemModel> get notifications {
    final seen = <String>{};
    final result = <NotificationItemModel>[];
    for (final n in [..._localNotifications, ..._remoteNotifications]) {
      if (_hiddenNotificationIds.contains(n.id) || !seen.add(n.id)) continue;
      final read = _readOverrides[n.id];
      result.add(read == null || read == n.isRead ? n : n.copyWith(isRead: read));
    }
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(result);
  }

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;
  bool get notificationsLoading => _notificationsLoading;
  Object? get notificationsError => _notificationsError;

  List<UserAddress> get savedAddresses => List.unmodifiable(_savedAddresses);
  List<RegisteredGear> get registeredGear => List.unmodifiable(_registeredGear);

  StreamSubscription<User?>? _authSubscription;

  AppState() {
    _initAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _notificationSub?.cancel();
    super.dispose();
  }

  void _initAuthListener() {
    if (!FirestoreService().isFirebaseAvailable) return;
    if (_authSubscription != null) return;
    try {
      _authSubscription = FirestoreService().auth.authStateChanges().listen((fbUser) async {
        if (_authInFlight) return;
        if (fbUser != null && !fbUser.isAnonymous) {
          if (_currentUser?.id != fbUser.uid || !_isAuthenticated) {
            await _syncFirebaseUser(fbUser);
          }
        } else if (_isAuthenticated) {
          _clearCart();
          _clearUserState();
          await _saveSessionToPrefs();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Auth state listener init error: $e');
    }
  }

  void _clearUserState() {
    _currentUser = null;
    _isAuthenticated = false;
    _savedAddresses = [];
    _registeredGear = [];
    _localNotifications.clear();
    _subscribeNotifications(); // switch to the guest audience
  }

  /// Loads the Firestore profile for [fbUser] and makes it the current user.
  /// A sync already running for the same uid is shared rather than repeated.
  Future<void> _syncFirebaseUser(User fbUser, {bool throwIfBlocked = false}) {
    final pending = _syncsInFlight[fbUser.uid];
    if (pending != null && !throwIfBlocked) return pending;
    final sync = _doSyncFirebaseUser(fbUser, throwIfBlocked: throwIfBlocked);
    _syncsInFlight[fbUser.uid] = sync;
    return sync.whenComplete(() {
      if (identical(_syncsInFlight[fbUser.uid], sync)) _syncsInFlight.remove(fbUser.uid);
    });
  }

  /// Creates a customer profile when none exists. If Firestore is unreachable the
  /// user stays signed in with the last known role. Deactivated accounts are signed
  /// out; with [throwIfBlocked] the caller gets a `user-disabled` error to show.
  Future<void> _doSyncFirebaseUser(User fbUser, {bool throwIfBlocked = false}) async {
    final fallbackName = (fbUser.displayName?.isNotEmpty ?? false)
        ? fbUser.displayName!
        : (fbUser.email?.split('@').first ?? 'Customer');
    final sameUser = _currentUser?.id == fbUser.uid;

    UserModel profile = UserModel(
      id: fbUser.uid,
      name: sameUser ? _currentUser!.name : fallbackName,
      email: fbUser.email ?? '',
      phone: sameUser ? _currentUser!.phone : (fbUser.phoneNumber ?? ''),
      role: sameUser ? _currentUser!.role : 'customer',
      technicianType: sameUser ? _currentUser!.technicianType : null,
      status: 'ACTIVE',
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );

    try {
      final doc = await FirestoreService()
          .db
          .collection('users')
          .doc(fbUser.uid)
          .get()
          .timeout(_profileTimeout);
      if (doc.exists && doc.data() != null) {
        profile = UserModel.fromFirestore(fbUser.uid, doc.data()!);
      } else {
        profile = await FirestoreService()
            .createCustomerProfile(user: fbUser, name: fallbackName, email: fbUser.email ?? '', phone: fbUser.phoneNumber ?? '')
            .timeout(_profileTimeout);
      }
    } catch (e) {
      debugPrint('Profile load failed, using last known profile: $e');
    }

    if (profile.status != 'ACTIVE') {
      await FirestoreService().signOut();
      _clearCart();
      _clearUserState();
      await _saveSessionToPrefs();
      notifyListeners();
      if (throwIfBlocked) throw FirebaseAuthException(code: 'user-disabled');
      return;
    }

    _currentUser = profile;
    _isAuthenticated = true;
    _subscribeNotifications();
    await _loadUserData(fbUser.uid);
    await _saveSessionToPrefs();
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // Addresses & registered gear: stored on the customer's own customers/{uid}
  // document (owner-only in firestore.rules), so they sync across devices and
  // aren't kept in plain local storage.
  // ----------------------------------------------------------------------

  static String _legacyAddressesKey(String uid) => 'svc_addresses_$uid';
  static String _legacyGearKey(String uid) => 'svc_gear_$uid';

  Future<void> _loadUserData(String userId) async {
    if (!FirestoreService().isFirebaseAvailable) return;
    Map<String, dynamic> data;
    try {
      final doc = await FirestoreService()
          .db
          .collection('customers')
          .doc(userId)
          .get()
          .timeout(_profileTimeout);
      data = doc.data() ?? const {};
    } catch (e) {
      debugPrint('Saved addresses not loaded: $e');
      return; // keep whatever is already shown
    }
    if (_currentUser?.id != userId) return; // signed out or switched meanwhile

    _savedAddresses = _parseList(data['savedAddresses'], UserAddress.fromMap);
    _registeredGear = _parseList(data['registeredGear'], RegisteredGear.fromMap);
    await _migrateLegacyUserData(userId);
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) parse) {
    if (raw is! List) return [];
    return [
      for (final e in raw)
        if (e is Map) parse(Map<String, dynamic>.from(e)),
    ];
  }

  /// Moves addresses/gear saved by older versions in plain SharedPreferences to
  /// Firestore (when Firestore has none yet), then deletes the local copies.
  Future<void> _migrateLegacyUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addrRaw = prefs.getString(_legacyAddressesKey(userId));
      final gearRaw = prefs.getString(_legacyGearKey(userId));
      if (addrRaw == null && gearRaw == null) return;

      var changed = false;
      if (_savedAddresses.isEmpty && addrRaw != null && addrRaw.isNotEmpty) {
        _savedAddresses = _parseList(jsonDecode(addrRaw), UserAddress.fromMap);
        changed = _savedAddresses.isNotEmpty;
      }
      if (_registeredGear.isEmpty && gearRaw != null && gearRaw.isNotEmpty) {
        final gear = _parseList(jsonDecode(gearRaw), RegisteredGear.fromMap);
        if (gear.isNotEmpty) {
          _registeredGear = gear;
          changed = true;
        }
      }
      if (changed) {
        await _userDataDoc(userId).set(_userDataFields(), SetOptions(merge: true)).timeout(_profileTimeout);
      }
      await prefs.remove(_legacyAddressesKey(userId));
      await prefs.remove(_legacyGearKey(userId));
    } catch (e, stack) {
      // Local copies are kept, so the next sign-in tries again.
      debugPrint('Legacy address migration failed: $e');
      _report(e, stack, 'Migrate saved addresses');
    }
  }

  DocumentReference<Map<String, dynamic>> _userDataDoc(String userId) =>
      FirestoreService().db.collection('customers').doc(userId);

  Map<String, dynamic> _userDataFields() => {
        'savedAddresses': _savedAddresses.map((a) => a.toMap()).toList(),
        'registeredGear': _registeredGear.map((g) => g.toMap()).toList(),
        'updatedAt': nowIsoUtc(),
      };

  /// Saves without waiting for the server: Firestore applies it to its local
  /// cache at once and syncs when online. Failures (e.g. rules) are reported.
  void _saveUserData(String userId) {
    if (!FirestoreService().isFirebaseAvailable) return;
    _userDataDoc(userId).set(_userDataFields(), SetOptions(merge: true)).catchError((Object e, StackTrace stack) {
      debugPrint('Error saving addresses: $e');
      _report(e, stack, 'Save addresses');
    });
  }

  static void _report(Object error, StackTrace stack, String reason) {
    if (Firebase.apps.isEmpty) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  }

  Future<void> addAddress(UserAddress address) async {
    if (_currentUser == null) return;
    if (address.isDefault) {
      _savedAddresses =
          _savedAddresses.map((a) => a.copyWith(isDefault: false)).toList();
    }
    _savedAddresses.add(address);
    _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    if (_currentUser == null) return;
    _savedAddresses.removeWhere((a) => a.id == id);
    if (_savedAddresses.isNotEmpty &&
        !_savedAddresses.any((a) => a.isDefault)) {
      _savedAddresses[0] = _savedAddresses[0].copyWith(isDefault: true);
    }
    _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    if (_currentUser == null) return;
    _savedAddresses =
        _savedAddresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> registerGear(RegisteredGear gear) async {
    if (_currentUser == null) return;
    _registeredGear.add(gear);
    _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> removeGear(String id) async {
    if (_currentUser == null) return;
    _registeredGear.removeWhere((g) => g.id == id);
    _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  /// Restores the session on app start without waiting on the network: Firebase Auth
  /// persists the signed-in user securely, so we show it immediately (with the last
  /// known role) and reconcile with Firestore in the background.
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _kLegacyPiiKeys) {
        await prefs.remove(key);
      }

      final savedHub = prefs.getString(_kSelectedDeliveryHub);
      if (savedHub != null && savedHub.isNotEmpty) {
        _selectedDeliveryHub = savedHub;
      }

      _loadCart(prefs);

      final fbUser = FirestoreService().auth.currentUser;
      if (fbUser != null && !fbUser.isAnonymous) {
        final cachedForThisUser = prefs.getString(_kUserId) == fbUser.uid;
        _currentUser = UserModel(
          id: fbUser.uid,
          name: (fbUser.displayName?.isNotEmpty ?? false) ? fbUser.displayName! : (fbUser.email?.split('@').first ?? 'Customer'),
          email: fbUser.email ?? '',
          phone: '',
          role: cachedForThisUser ? (prefs.getString(_kUserRole) ?? 'customer') : 'customer',
          technicianType: cachedForThisUser ? prefs.getString(_kUserTechType) : null,
          status: 'ACTIVE',
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );
        _isAuthenticated = true;
        // Profile, addresses and gear load in the background.
        _sessionReconcile = _syncFirebaseUser(fbUser);
      } else {
        _clearUserState();
        await _saveSessionToPrefs();
      }
    } catch (e) {
      debugPrint('Session restore note: $e');
    } finally {
      _isSessionLoaded = true;
      _subscribeNotifications();
      notifyListeners();
    }
  }

  /// Completes when the background profile check from [loadSession] finishes,
  /// or after [timeout] so a slow network never blocks the app.
  Future<void> waitForSession({Duration timeout = const Duration(seconds: 4)}) async {
    final pending = _sessionReconcile;
    if (pending == null) return;
    await pending.timeout(timeout, onTimeout: () {});
  }

  Future<void> _saveSessionToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isAuthenticated && _currentUser != null) {
        // Only non-identifying data: uid and role, used to restore the UI quickly.
        await prefs.setBool(_kIsLoggedIn, true);
        await prefs.setString(_kUserId, _currentUser!.id);
        await prefs.setString(_kUserRole, _currentUser!.role);
        if (_currentUser!.technicianType != null) {
          await prefs.setString(_kUserTechType, _currentUser!.technicianType!);
        } else {
          await prefs.remove(_kUserTechType);
        }
      } else {
        await prefs.setBool(_kIsLoggedIn, false);
        await prefs.remove(_kUserId);
        await prefs.remove(_kUserRole);
        await prefs.remove(_kUserTechType);
      }
    } catch (e) {
      debugPrint('Local storage note: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    _authInFlight = true;
    try {
      final fbUser = await FirestoreService().signIn(email: email, password: password);
      _initAuthListener();
      await _syncFirebaseUser(fbUser, throwIfBlocked: true);
    } finally {
      _authInFlight = false;
    }
  }

  Future<void> signInWithGoogle() async {
    _authInFlight = true;
    try {
      final fbUser = await FirestoreService().signInWithGoogle();
      _initAuthListener();
      await _syncFirebaseUser(fbUser, throwIfBlocked: true);
    } finally {
      _authInFlight = false;
    }
  }

  Future<void> signInWithApple() async {
    _authInFlight = true;
    try {
      final fbUser = await FirestoreService().signInWithApple();
      _initAuthListener();
      await _syncFirebaseUser(fbUser, throwIfBlocked: true);
    } finally {
      _authInFlight = false;
    }
  }

  bool get hasPasswordSignIn => FirestoreService().hasPasswordSignIn;

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _authInFlight = true;
    try {
      final user = await FirestoreService().signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _initAuthListener();
      _currentUser = user;
      _isAuthenticated = true;
      _subscribeNotifications();
      await _loadUserData(user.id);
      await _saveSessionToPrefs();
      notifyListeners();
    } finally {
      _authInFlight = false;
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    if (_currentUser == null) return false;

    await FirestoreService().updateUserProfile(
      uid: _currentUser!.id,
      name: name,
      phone: phone,
    );

    // Same normalisation the service saved, so the screen matches Firestore.
    _currentUser = _currentUser!.copyWith(
      name: name.trim(),
      phone: FirestoreService.isValidNepalMobile(phone)
          ? FirestoreService.normalizeNepalPhone(phone)
          : phone.trim(),
    );

    await _saveSessionToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await FirestoreService().changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  bool get isEmailVerified => FirestoreService().isEmailVerified;

  Future<void> resendVerificationEmail() =>
      FirestoreService().resendVerificationEmail();

  Future<void> deleteAccount({String? currentPassword}) async {
    final uid = _currentUser?.id;
    // Also deletes customers/{uid}, which holds the saved addresses and gear.
    await FirestoreService().deleteAccount(currentPassword: currentPassword);
    if (uid != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_legacyAddressesKey(uid));
        await prefs.remove(_legacyGearKey(uid));
        await prefs.remove('$_kHiddenNotificationsPrefix$uid');
      } catch (_) {}
    }
    await signOut();
  }

  Future<void> signOut() async {
    await FirestoreService().signOut();
    _clearCart(); // the next person on this phone starts with an empty cart
    _clearUserState();
    await _saveSessionToPrefs();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    await FirestoreService().sendPasswordResetEmail(email);
    return true;
  }

  // ----------------------------------------------------------------------
  // Cart (persisted on the device so it survives restarts)
  // ----------------------------------------------------------------------

  void _loadCart(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_kCart);
      if (raw == null || raw.isEmpty) return;
      _cartItems
        ..clear()
        ..addAll(_parseList(jsonDecode(raw), CartItemModel.fromMap).where((i) => i.productId.isNotEmpty));
    } catch (e) {
      debugPrint('Saved cart not restored: $e');
    }
  }

  void _cartChanged() {
    notifyListeners();
    _saveCart();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_cartItems.isEmpty) {
        await prefs.remove(_kCart);
      } else {
        await prefs.setString(_kCart, jsonEncode(_cartItems.map((i) => i.toMap()).toList()));
      }
    } catch (e) {
      debugPrint('Cart not saved: $e');
    }
  }

  void _clearCart() {
    _cartItems.clear();
    _saveCart();
  }

  void addToCart(CartItemModel newItem) {
    final existingIndex =
        _cartItems.indexWhere((i) => i.productId == newItem.productId);
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += newItem.quantity;
    } else {
      _cartItems.add(newItem);
    }
    _cartChanged();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cartItems.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      _cartItems[index].quantity = quantity;
      _cartChanged();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.productId == productId);
    _cartChanged();
  }

  void clearCart() {
    _cartItems.clear();
    _cartChanged();
  }

  void setDeliveryHub(String hub) async {
    _selectedDeliveryHub = hub;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSelectedDeliveryHub, hub);
    } catch (_) {}
  }

  // ----------------------------------------------------------------------
  // Notifications (live for the whole session, so badges are always current)
  // ----------------------------------------------------------------------

  /// Listens to the notifications for the current audience (a signed-in user or
  /// guests). Does nothing if already listening for that audience.
  void _subscribeNotifications() {
    if (!FirestoreService().isFirebaseAvailable) return;
    final user = _currentUser;
    final audience = user?.id ?? 'guest';
    if (_notificationSub != null && _notificationAudience == audience) return;

    _notificationSub?.cancel();
    _notificationAudience = audience;
    _remoteNotifications = [];
    _readOverrides.clear();
    _hiddenNotificationIds = {};
    _notificationsLoading = true;
    _notificationsError = null;
    _loadNotificationPrefs(audience);

    _notificationSub = FirestoreService()
        .streamNotifications(userId: user?.id, isGuest: user == null)
        .listen((list) {
      _remoteNotifications = list;
      _notificationsLoading = false;
      _notificationsError = null;
      _pruneHiddenNotifications();
      notifyListeners();
    }, onError: (Object e) {
      _notificationsLoading = false;
      _notificationsError = e;
      notifyListeners();
    });
  }

  /// Pull-to-refresh / retry: listens again from scratch.
  Future<void> refreshNotifications() async {
    _notificationSub?.cancel();
    _notificationSub = null;
    _subscribeNotifications();
    notifyListeners();
  }

  Future<void> _loadNotificationPrefs(String audience) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_notificationAudience != audience) return;
      _hiddenNotificationIds = {
        ..._hiddenNotificationIds,
        ...?prefs.getStringList('$_kHiddenNotificationsPrefix$audience'),
      };
      if (audience == 'guest') {
        for (final id in prefs.getStringList(_kGuestReadNotifications) ?? const <String>[]) {
          _readOverrides.putIfAbsent(id, () => true);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Notification preferences not loaded: $e');
    }
  }

  Future<void> _saveNotificationPrefs() async {
    final audience = _notificationAudience;
    if (audience == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('$_kHiddenNotificationsPrefix$audience', _hiddenNotificationIds.toList());
      if (audience == 'guest') {
        await prefs.setStringList(
          _kGuestReadNotifications,
          [for (final e in _readOverrides.entries) if (e.value) e.key],
        );
      }
    } catch (e) {
      debugPrint('Notification preferences not saved: $e');
    }
  }

  /// Forgets removed ids whose notification no longer exists, so the list stays small.
  void _pruneHiddenNotifications() {
    final known = {for (final n in _remoteNotifications) n.id, for (final n in _localNotifications) n.id};
    final before = _hiddenNotificationIds.length;
    _hiddenNotificationIds.retainWhere(known.contains);
    if (_hiddenNotificationIds.length != before) _saveNotificationPrefs();
  }

  /// Applies [read] at once and saves it: to Firestore `readBy` for a signed-in
  /// user's server notifications, on the device for guests.
  void _setNotificationsRead(Iterable<String> ids, bool read) {
    final list = ids.toList();
    if (list.isEmpty) return;
    for (final id in list) {
      _readOverrides[id] = read;
    }
    notifyListeners();
    _saveNotificationPrefs();

    final uid = _currentUser?.id;
    if (uid == null || !FirestoreService().isFirebaseAvailable) return;
    final remoteIds = {for (final n in _remoteNotifications) n.id};
    final toWrite = list.where(remoteIds.contains);
    if (toWrite.isNotEmpty) {
      FirestoreService().setNotificationsRead(toWrite, userId: uid, read: read);
    }
  }

  void markNotificationAsRead(String id) {
    final n = notifications.where((n) => n.id == id).firstOrNull;
    if (n != null && !n.isRead) _setNotificationsRead([id], true);
  }

  void toggleNotificationRead(String id) {
    final n = notifications.where((n) => n.id == id).firstOrNull;
    if (n != null) _setNotificationsRead([id], !n.isRead);
  }

  void markAllNotificationsAsRead() {
    _setNotificationsRead([for (final n in notifications) if (!n.isRead) n.id], true);
  }

  /// Removal is remembered on this device; shared broadcasts can't be deleted.
  void _hideNotifications(Iterable<String> ids) {
    _hiddenNotificationIds.addAll(ids);
    notifyListeners();
    _saveNotificationPrefs();
  }

  void removeNotification(String id) => _hideNotifications([id]);

  void clearAllNotifications() => _hideNotifications([for (final n in notifications) n.id]);

  void clearReadNotifications() =>
      _hideNotifications([for (final n in notifications) if (n.isRead) n.id]);

  /// Adds a notification created on the device, or restores a removed one (undo).
  void addNotification(NotificationItemModel item) {
    if (_hiddenNotificationIds.remove(item.id)) {
      _saveNotificationPrefs();
    } else if (!_localNotifications.any((n) => n.id == item.id) &&
        !_remoteNotifications.any((n) => n.id == item.id)) {
      _localNotifications.insert(0, item);
    }
    notifyListeners();
  }
}
