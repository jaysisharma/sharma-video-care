import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharma_video_care_mobile/screens/home_screen.dart';
import 'package:sharma_video_care_mobile/screens/shop_screen.dart';
import 'package:sharma_video_care_mobile/screens/used_screen.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';

void main() {
  testWidgets('HomeScreen renders without crashing when Firebase is uninitialized', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(appState: appState, onNavigateTab: (_) {}),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('ShopScreen renders without crashing when Firebase is uninitialized', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      MaterialApp(
        home: ShopScreen(appState: appState),
      ),
    );
    expect(find.byType(ShopScreen), findsOneWidget);
  });

  testWidgets('UsedProductsScreen renders without crashing when Firebase is uninitialized', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      MaterialApp(
        home: UsedProductsScreen(appState: appState),
      ),
    );
    expect(find.byType(UsedProductsScreen), findsOneWidget);
  });
}
