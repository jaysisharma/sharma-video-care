import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class AppState extends ChangeNotifier {
  static const String _kIsLoggedIn = 'svc_is_logged_in';
  static const String _kUserId = 'svc_user_id';
  static const String _kUserName = 'svc_user_name';
  static const String _kUserEmail = 'svc_user_email';
  static const String _kUserPhone = 'svc_user_phone';
  static const String _kUserRole = 'svc_user_role';
  static const String _kUserTechType = 'svc_user_tech_type';
  static const String _kUserPersonaId = 'svc_user_persona_id';

  DemoPersona _currentPersona = kDemoPersonas[0];
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isSessionLoaded = false;
  final List<CartItemModel> _cartItems = [];

  DemoPersona get currentPersona => _currentPersona;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isSessionLoaded => _isSessionLoaded;
  String get role => _currentUser?.role ?? _currentPersona.role;
  String? get technicianType => _currentUser?.technicianType ?? _currentPersona.technicianType;

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.fold(0, (acc, item) => acc + item.quantity);
  int get cartSubtotal => _cartItems.fold(0, (acc, item) => acc + item.totalPrice);
  int get deliveryFee => _cartItems.isNotEmpty ? 150 : 0;
  int get cartTotal => cartSubtotal + deliveryFee;

  AppState() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      FirestoreService().auth.authStateChanges().listen((fbUser) async {
        if (fbUser != null && !fbUser.isAnonymous) {
          if (_currentUser?.id != fbUser.uid || !_isAuthenticated) {
            await _syncFirebaseUser(fbUser);
          }
        }
      });
    } catch (e) {
      debugPrint('Auth state listener init error: $e');
    }
  }

  /// Synchronizes Firebase User and Firestore profile with AppState and SharedPreferences
  Future<void> _syncFirebaseUser(dynamic fbUser) async {
    try {
      String name = fbUser.displayName ?? '';
      if (name.isEmpty && fbUser.email != null && fbUser.email!.isNotEmpty) {
        name = fbUser.email!.split('@')[0];
      }
      if (name.isEmpty) name = 'Customer';

      String email = fbUser.email ?? '';
      String phone = fbUser.phoneNumber ?? '';
      String role = 'customer';
      String? techType;
      String status = 'ACTIVE';
      DateTime createdAt = fbUser.metadata?.creationTime ?? DateTime.now();

      try {
        final doc = await FirestoreService().db.collection('users').doc(fbUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          name = data['name'] ?? name;
          email = data['email'] ?? email;
          phone = data['phone'] ?? phone;
          role = data['role'] ?? role;
          techType = data['technicianType'];
          status = data['status'] ?? status;
          createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? createdAt;
        } else {
          // If Firestore user doc doesn't exist yet, save it
          await FirestoreService().db.collection('users').doc(fbUser.uid).set({
            'name': name,
            'email': email,
            'phone': phone,
            'role': role,
            'status': status,
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      } catch (err) {
        debugPrint('Firestore profile fetch notice: $err');
      }

      _currentUser = UserModel(
        id: fbUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        technicianType: techType,
        status: status,
        createdAt: createdAt,
      );

      _currentPersona = DemoPersona(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        role: _currentUser!.role,
        technicianType: _currentUser!.technicianType,
        label: _currentUser!.name,
      );

      _isAuthenticated = true;
      await _saveSessionToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to sync Firebase user: $e');
    }
  }

  /// Loads persisted user session on app start
  Future<void> loadSession() async {
    // 1. Instant local restore from SharedPreferences (if available)
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;

      if (isLoggedIn) {
        final personaId = prefs.getString(_kUserPersonaId);
        final email = prefs.getString(_kUserEmail) ?? '';
        final name = prefs.getString(_kUserName) ?? '';
        final phone = prefs.getString(_kUserPhone) ?? '';
        final role = prefs.getString(_kUserRole) ?? 'customer';
        final techType = prefs.getString(_kUserTechType);
        final id = prefs.getString(_kUserId) ?? 'user-1';

        DemoPersona? matched;
        if (personaId != null) {
          for (final p in kDemoPersonas) {
            if (p.id == personaId) {
              matched = p;
              break;
            }
          }
        }
        if (matched == null && email.isNotEmpty) {
          for (final p in kDemoPersonas) {
            if (p.email.toLowerCase() == email.toLowerCase()) {
              matched = p;
              break;
            }
          }
        }

        if (matched != null) {
          _currentPersona = matched;
          _currentUser = UserModel.fromPersona(matched);
        } else {
          final persona = DemoPersona(
            id: id,
            name: name.isNotEmpty ? name : 'Customer',
            email: email,
            phone: phone,
            role: role,
            technicianType: techType,
            label: name.isNotEmpty ? name : 'Customer',
          );
          _currentPersona = persona;
          _currentUser = UserModel.fromPersona(persona);
        }
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Local prefs cache note (will use live Firebase Auth): $e');
    }

    // 2. Check live Firebase Auth user (independently of SharedPreferences)
    try {
      final fbUser = FirestoreService().auth.currentUser;
      if (fbUser != null && !fbUser.isAnonymous) {
        await _syncFirebaseUser(fbUser);
      }
    } catch (e) {
      debugPrint('Firebase Auth restore note: $e');
    } finally {
      _isSessionLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveSessionToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isAuthenticated && _currentUser != null) {
        await prefs.setBool(_kIsLoggedIn, true);
        await prefs.setString(_kUserId, _currentUser!.id);
        await prefs.setString(_kUserName, _currentUser!.name);
        await prefs.setString(_kUserEmail, _currentUser!.email);
        await prefs.setString(_kUserPhone, _currentUser!.phone);
        await prefs.setString(_kUserRole, _currentUser!.role);
        if (_currentUser!.technicianType != null) {
          await prefs.setString(_kUserTechType, _currentUser!.technicianType!);
        } else {
          await prefs.remove(_kUserTechType);
        }
        await prefs.setString(_kUserPersonaId, _currentPersona.id);
      } else {
        await prefs.setBool(_kIsLoggedIn, false);
        await prefs.remove(_kUserId);
        await prefs.remove(_kUserName);
        await prefs.remove(_kUserEmail);
        await prefs.remove(_kUserPhone);
        await prefs.remove(_kUserRole);
        await prefs.remove(_kUserTechType);
        await prefs.remove(_kUserPersonaId);
      }
    } catch (e) {
      debugPrint('Local storage note: $e');
    }
  }

  Future<void> switchPersona(DemoPersona persona) async {
    _currentPersona = persona;
    _currentUser = UserModel.fromPersona(persona);
    _isAuthenticated = true;
    await _saveSessionToPrefs();
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    final user = await FirestoreService().signIn(
      email: email,
      password: password,
    );

    _currentUser = user;
    _currentPersona = DemoPersona(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      technicianType: user.technicianType,
      label: user.name,
    );
    _isAuthenticated = true;
    await _saveSessionToPrefs();
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = await FirestoreService().signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    _currentUser = user;
    _currentPersona = DemoPersona(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      technicianType: user.technicianType,
      label: user.name,
    );
    _isAuthenticated = true;
    await _saveSessionToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await FirestoreService().signOut();
    _isAuthenticated = false;
    _currentUser = null;
    await _saveSessionToPrefs();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    await FirestoreService().sendPasswordResetEmail(email);
    return true;
  }

  void addToCart(CartItemModel newItem) {
    final existingIndex = _cartItems.indexWhere((i) => i.productId == newItem.productId);
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
}
