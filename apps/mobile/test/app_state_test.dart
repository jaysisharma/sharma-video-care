import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';
import 'package:sharma_video_care_mobile/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Cart Operations Tests', () {
    late AppState appState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
      appState.clearCart();
    });

    test('Initial cart is empty with zero subtotal and delivery fee', () {
      expect(appState.cartItems.isEmpty, isTrue);
      expect(appState.cartCount, equals(0));
      expect(appState.cartSubtotal, equals(0));
      expect(appState.deliveryFee, equals(0));
      expect(appState.cartTotal, equals(0));
      expect(appState.getItemQuantity('prod-1'), equals(0));
    });

    test('Adding single item to cart updates counts and calculates total', () {
      final item = CartItemModel(
        productId: 'prod-sony-a7iv',
        productType: 'NEW',
        name: 'Sony Alpha 7 IV Cinema Camera',
        unitPrice: 320000,
        quantity: 1,
      );

      appState.addToCart(item);

      expect(appState.cartItems.length, equals(1));
      expect(appState.cartCount, equals(1));
      expect(appState.cartSubtotal, equals(320000));
      expect(appState.deliveryFee, equals(150));
      expect(appState.cartTotal, equals(320150));
      expect(appState.getItemQuantity('prod-sony-a7iv'), equals(1));
    });

    test('Adding duplicate item increments existing item quantity', () {
      final item1 = CartItemModel(
        productId: 'prod-lens-24-70',
        productType: 'NEW',
        name: 'FE 24-70mm F2.8 GM II',
        unitPrice: 245000,
        quantity: 1,
      );
      final item2 = CartItemModel(
        productId: 'prod-lens-24-70',
        productType: 'NEW',
        name: 'FE 24-70mm F2.8 GM II',
        unitPrice: 245000,
        quantity: 2,
      );

      appState.addToCart(item1);
      appState.addToCart(item2);

      expect(appState.cartItems.length, equals(1));
      expect(appState.cartCount, equals(3));
      expect(appState.cartSubtotal, equals(245000 * 3));
      expect(appState.getItemQuantity('prod-lens-24-70'), equals(3));
    });

    test('Updating item quantity adjusts subtotal and removing when zero', () {
      final item = CartItemModel(
        productId: 'prod-battery-npfz100',
        productType: 'NEW',
        name: 'Sony NP-FZ100 Rechargeable Battery',
        unitPrice: 9500,
        quantity: 3,
      );

      appState.addToCart(item);
      expect(appState.cartCount, equals(3));

      // Update quantity to 5
      appState.updateQuantity('prod-battery-npfz100', 5);
      expect(appState.cartCount, equals(5));
      expect(appState.cartSubtotal, equals(9500 * 5));

      // Update quantity to 0 removes item
      appState.updateQuantity('prod-battery-npfz100', 0);
      expect(appState.cartItems.isEmpty, isTrue);
      expect(appState.cartCount, equals(0));
      expect(appState.cartTotal, equals(0));
    });

    test('Removing item from cart updates cart properly', () {
      final item1 = CartItemModel(
        productId: 'item-1',
        productType: 'NEW',
        name: 'Item 1',
        unitPrice: 1000,
        quantity: 1,
      );
      final item2 = CartItemModel(
        productId: 'item-2',
        productType: 'NEW',
        name: 'Item 2',
        unitPrice: 2000,
        quantity: 2,
      );

      appState.addToCart(item1);
      appState.addToCart(item2);
      expect(appState.cartItems.length, equals(2));

      appState.removeFromCart('item-1');
      expect(appState.cartItems.length, equals(1));
      expect(appState.cartItems.first.productId, equals('item-2'));
      expect(appState.cartSubtotal, equals(4000));
    });

    test('Clearing cart removes all items and resets totals', () {
      appState.addToCart(CartItemModel(
        productId: 'item-1',
        productType: 'NEW',
        name: 'Item 1',
        unitPrice: 5000,
        quantity: 2,
      ));

      expect(appState.cartItems.isNotEmpty, isTrue);
      appState.clearCart();

      expect(appState.cartItems.isEmpty, isTrue);
      expect(appState.cartCount, equals(0));
      expect(appState.cartSubtotal, equals(0));
      expect(appState.deliveryFee, equals(0));
      expect(appState.cartTotal, equals(0));
    });
  });

  group('AppState Notifications State Tests', () {
    late AppState appState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      appState = AppState();
    });

    test('Notifications list is empty by default for clean guest session', () {
      expect(appState.notifications.isEmpty, isTrue);
      expect(appState.unreadNotificationCount, equals(0));
    });

    test('markNotificationAsRead marks specific item as read', () {
      final notif = NotificationItemModel(
        id: 'test-n1',
        title: 'Title',
        message: 'Message',
        category: 'repairs',
        timestamp: DateTime.now(),
        isRead: false,
      );
      appState.addNotification(notif);
      expect(appState.unreadNotificationCount, equals(1));

      appState.markNotificationAsRead(notif.id);

      final updated = appState.notifications.firstWhere((n) => n.id == notif.id);
      expect(updated.isRead, isTrue);
      expect(appState.unreadNotificationCount, equals(0));
    });

    test('toggleNotificationRead toggles read state back and forth', () {
      final notif = NotificationItemModel(
        id: 'test-n2',
        title: 'Title',
        message: 'Message',
        category: 'orders',
        timestamp: DateTime.now(),
        isRead: false,
      );
      appState.addNotification(notif);

      appState.toggleNotificationRead(notif.id);
      expect(appState.notifications.firstWhere((n) => n.id == notif.id).isRead, isTrue);

      appState.toggleNotificationRead(notif.id);
      expect(appState.notifications.firstWhere((n) => n.id == notif.id).isRead, isFalse);
    });

    test('markAllNotificationsAsRead marks all notifications as read', () {
      appState.addNotification(NotificationItemModel(
        id: 'test-1',
        title: 'A',
        message: 'A',
        category: 'orders',
        timestamp: DateTime.now(),
        isRead: false,
      ));
      appState.addNotification(NotificationItemModel(
        id: 'test-2',
        title: 'B',
        message: 'B',
        category: 'repairs',
        timestamp: DateTime.now(),
        isRead: false,
      ));
      expect(appState.unreadNotificationCount, equals(2));

      appState.markAllNotificationsAsRead();

      expect(appState.unreadNotificationCount, equals(0));
      expect(appState.notifications.every((n) => n.isRead), isTrue);
    });

    test('addNotification adds item to start of list', () {
      final initialCount = appState.notifications.length;
      final newNotif = NotificationItemModel(
        id: 'test-notif-custom',
        title: 'Diagnostic Complete',
        message: 'Your lens calibration is complete and ready for dispatch.',
        category: 'repairs',
        timestamp: DateTime.now(),
        isRead: false,
      );

      appState.addNotification(newNotif);

      expect(appState.notifications.length, equals(initialCount + 1));
      expect(appState.notifications.first.id, equals('test-notif-custom'));
      expect(appState.notifications.first.title, equals('Diagnostic Complete'));
    });

    test('removeNotification removes specific notification', () {
      final notif = NotificationItemModel(
        id: 'test-to-remove',
        title: 'Title',
        message: 'Message',
        category: 'repairs',
        timestamp: DateTime.now(),
        isRead: false,
      );
      appState.addNotification(notif);
      final initialCount = appState.notifications.length;

      appState.removeNotification('test-to-remove');

      expect(appState.notifications.length, equals(initialCount - 1));
      expect(appState.notifications.any((n) => n.id == 'test-to-remove'), isFalse);
    });

    test('clearAllNotifications empties the notification list', () {
      appState.addNotification(NotificationItemModel(
        id: 'test-clear-1',
        title: 'A',
        message: 'A',
        category: 'orders',
        timestamp: DateTime.now(),
        isRead: false,
      ));
      expect(appState.notifications.isNotEmpty, isTrue);

      appState.clearAllNotifications();

      expect(appState.notifications.isEmpty, isTrue);
      expect(appState.unreadNotificationCount, equals(0));
    });

    test('clearReadNotifications removes only read items', () {
      appState.addNotification(NotificationItemModel(
        id: 'unread-item',
        title: 'Unread',
        message: 'Unread',
        category: 'repairs',
        timestamp: DateTime.now(),
        isRead: false,
      ));
      appState.addNotification(NotificationItemModel(
        id: 'read-item',
        title: 'Read',
        message: 'Read',
        category: 'offers',
        timestamp: DateTime.now(),
        isRead: true,
      ));
      expect(appState.notifications.length, equals(2));
      expect(appState.unreadNotificationCount, equals(1));

      appState.clearReadNotifications();

      expect(appState.notifications.length, equals(1));
      expect(appState.notifications.first.id, equals('unread-item'));
      expect(appState.notifications.every((n) => !n.isRead), isTrue);
    });
  });

  group('Cart persistence', () {
    test('the cart is restored after an app restart', () async {
      SharedPreferences.setMockInitialValues({});
      final first = AppState();
      first.addToCart(CartItemModel(productId: 'prod-1', productType: 'NEW', name: 'Sony A7 IV', unitPrice: 310000, quantity: 2));
      await Future<void>.delayed(Duration.zero); // let the save finish

      final restarted = AppState();
      await restarted.loadSession();
      expect(restarted.getItemQuantity('prod-1'), 2);
      expect(restarted.cartSubtotal, 620000);
    });
  });
}
