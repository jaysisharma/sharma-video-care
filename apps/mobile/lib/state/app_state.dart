import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isSessionLoaded = false;
  // True while signIn/signUp run; they load the profile themselves, so the auth
  // listener must not race them with a fallback profile write.
  bool _authInFlight = false;
  Future<void>? _sessionReconcile;
  static const Duration _profileTimeout = Duration(seconds: 6);
  final List<CartItemModel> _cartItems = [];
  String _selectedDeliveryHub = 'Janakpur Hub';
  List<UserAddress> _savedAddresses = [];
  List<RegisteredGear> _registeredGear = [];

  final List<NotificationItemModel> _notifications = [];

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

  List<NotificationItemModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  List<UserAddress> get savedAddresses => List.unmodifiable(_savedAddresses);
  List<RegisteredGear> get registeredGear => List.unmodifiable(_registeredGear);

  AppState() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      FirestoreService().auth.authStateChanges().listen((fbUser) async {
        if (_authInFlight) return;
        if (fbUser != null && !fbUser.isAnonymous) {
          if (_currentUser?.id != fbUser.uid || !_isAuthenticated) {
            await _syncFirebaseUser(fbUser);
          }
        } else if (_isAuthenticated) {
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
    _notifications.clear();
  }

  /// Loads the Firestore profile for [fbUser] and makes it the current user.
  /// Creates a customer profile when none exists. If Firestore is unreachable the
  /// user stays signed in with the last known role. Deactivated accounts are signed
  /// out; with [throwIfBlocked] the caller gets a `user-disabled` error to show.
  Future<void> _syncFirebaseUser(User fbUser, {bool throwIfBlocked = false}) async {
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
      _clearUserState();
      await _saveSessionToPrefs();
      notifyListeners();
      if (throwIfBlocked) throw FirebaseAuthException(code: 'user-disabled');
      return;
    }

    _currentUser = profile;
    _isAuthenticated = true;
    await _loadUserData(fbUser.uid);
    await _saveSessionToPrefs();
    notifyListeners();
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addrRaw = prefs.getString('svc_addresses_$userId');
      if (addrRaw != null && addrRaw.isNotEmpty) {
        final List list = jsonDecode(addrRaw);
        _savedAddresses = list
            .map((e) => UserAddress.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _savedAddresses = [];
      }

      final gearRaw = prefs.getString('svc_gear_$userId');
      if (gearRaw != null && gearRaw.isNotEmpty) {
        final List list = jsonDecode(gearRaw);
        _registeredGear = list
            .map((e) => RegisteredGear.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _registeredGear = [];
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'svc_addresses_$userId',
        jsonEncode(_savedAddresses.map((a) => a.toMap()).toList()),
      );
      await prefs.setString(
        'svc_gear_$userId',
        jsonEncode(_registeredGear.map((g) => g.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> addAddress(UserAddress address) async {
    if (_currentUser == null) return;
    if (address.isDefault) {
      _savedAddresses =
          _savedAddresses.map((a) => a.copyWith(isDefault: false)).toList();
    }
    _savedAddresses.add(address);
    await _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    if (_currentUser == null) return;
    _savedAddresses.removeWhere((a) => a.id == id);
    if (_savedAddresses.isNotEmpty &&
        !_savedAddresses.any((a) => a.isDefault)) {
      _savedAddresses[0] = _savedAddresses[0].copyWith(isDefault: true);
    }
    await _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    if (_currentUser == null) return;
    _savedAddresses =
        _savedAddresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    await _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> registerGear(RegisteredGear gear) async {
    if (_currentUser == null) return;
    _registeredGear.add(gear);
    await _saveUserData(_currentUser!.id);
    notifyListeners();
  }

  Future<void> removeGear(String id) async {
    if (_currentUser == null) return;
    _registeredGear.removeWhere((g) => g.id == id);
    await _saveUserData(_currentUser!.id);
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
        await _loadUserData(fbUser.uid);
        _sessionReconcile = _syncFirebaseUser(fbUser);
      } else {
        _clearUserState();
        await _saveSessionToPrefs();
      }
    } catch (e) {
      debugPrint('Session restore note: $e');
    } finally {
      _isSessionLoaded = true;
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
      await _syncFirebaseUser(fbUser, throwIfBlocked: true);
    } finally {
      _authInFlight = false;
    }
  }

  Future<void> signInWithGoogle() async {
    _authInFlight = true;
    try {
      final fbUser = await FirestoreService().signInWithGoogle();
      await _syncFirebaseUser(fbUser, throwIfBlocked: true);
    } finally {
      _authInFlight = false;
    }
  }

  Future<void> signInWithApple() async {
    _authInFlight = true;
    try {
      final fbUser = await FirestoreService().signInWithApple();
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
      _currentUser = user;
      _isAuthenticated = true;
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

    _currentUser = _currentUser!.copyWith(
      name: name.trim(),
      phone: phone.trim(),
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
    await FirestoreService().deleteAccount(currentPassword: currentPassword);
    if (uid != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('svc_addresses_$uid');
        await prefs.remove('svc_gear_$uid');
      } catch (_) {}
    }
    await signOut();
  }

  Future<void> signOut() async {
    await FirestoreService().signOut();
    _clearUserState();
    await _saveSessionToPrefs();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    await FirestoreService().sendPasswordResetEmail(email);
    return true;
  }

  void addToCart(CartItemModel newItem) {
    final existingIndex =
        _cartItems.indexWhere((i) => i.productId == newItem.productId);
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += newItem.quantity;
    } else {
      _cartItems.add(newItem);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cartItems.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void setDeliveryHub(String hub) async {
    _selectedDeliveryHub = hub;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSelectedDeliveryHub, hub);
    } catch (_) {}
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void toggleNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: !_notifications[index].isRead,
      );
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void clearReadNotifications() {
    _notifications.removeWhere((n) => n.isRead);
    notifyListeners();
  }

  void addNotification(NotificationItemModel item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}
