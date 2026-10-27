import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/models/models.dart';
import 'package:sharma_video_care_mobile/screens/search_screen.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';
import 'package:sharma_video_care_mobile/utils/search.dart';

import 'fixtures/used_products_fixture.dart';

ProductModel _product(String id, String name, String brand, String category) =>
    ProductModel.fromFirestore(id, {
      'name': name,
      'brand': brand,
      'categoryName': category,
      'price': 100000,
      'availabilityType': 'IN_STOCK',
      'stockQuantity': 5,
    });

void main() {
  test('a plural only falls back to its singular as a whole word', () {
    expect(searchScore('lens', ['Lenovo ThinkPad X1']), 0);
    expect(searchScore('lenses', ['Canon RF 50mm Lens']), greaterThan(0));
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('searchScore', () {
    test('every query word must match somewhere', () {
      expect(searchScore('sony lens', ['Sony FE 50mm f/1.8', 'Sony', 'Lenses']), greaterThan(0));
      expect(searchScore('sony drone', ['Sony FE 50mm f/1.8', 'Sony', 'Lenses']), 0);
      expect(searchScore('   ', ['Anything']), 0);
    });

    test('ignores case and punctuation, and matches plurals to singular', () {
      expect(searchScore('F1.8', ['Sony FE 50mm f/1.8']), greaterThan(0));
      expect(searchScore('lenses', ['Canon RF Lens']), greaterThan(0));
      expect(searchScore('cameras', ['Camera Body']), greaterThan(0));
      expect(searchScore('a7iv', ['Sony A7 IV Body']), greaterThan(0));
    });

    test('name matches rank above description matches', () {
      final ranked = rankSearch<List<String>>(
        'canon',
        [
          ['Lens cap', 'Fits Canon RF bodies'],
          ['Canon EOS R5', 'Mirrorless body'],
        ],
        (f) => f,
      );
      expect(ranked.first.first, 'Canon EOS R5');
      expect(ranked.length, 2);
    });
  });

  group('SearchScreen', () {
    Future<void> pumpSearch(WidgetTester tester, {String query = ''}) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: SearchScreen(
          appState: AppState(),
          initialQuery: query,
          productsStream: Stream.value([
            _product('p1', 'Canon EOS R5 Mirrorless Body', 'Canon', 'Cameras'),
            _product('p2', 'DJI Mini 4 Pro Drone', 'DJI', 'Drones'),
          ]),
          usedProductsStream: Stream.value(kSampleUsedProducts),
        ),
      ));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows popular searches before typing', (tester) async {
      await pumpSearch(tester);
      expect(find.text('Popular searches'), findsOneWidget);
      expect(find.text('Canon'), findsOneWidget);
    });

    testWidgets('groups results by type with counts', (tester) async {
      await pumpSearch(tester, query: 'canon');
      expect(tester.takeException(), isNull);
      expect(find.text('Canon EOS R5 Mirrorless Body'), findsOneWidget); // new product
      expect(find.text('Canon EOS 5D Mark IV DSLR Body'), findsOneWidget); // pre-owned
      expect(find.text('Products (1)'), findsOneWidget);
      expect(find.text('Pre-Owned (1)'), findsOneWidget);
    });

    testWidgets('finds repair services', (tester) async {
      await pumpSearch(tester, query: 'sensor clean');
      expect(find.text('Repair Services'), findsOneWidget);
      expect(find.textContaining('Sensor Micro-Clean'), findsOneWidget);
    });

    testWidgets('tabs narrow the results', (tester) async {
      await pumpSearch(tester, query: 'drone');
      final preOwnedTab = find.textContaining('Pre-Owned (');
      await tester.ensureVisible(preOwnedTab); // tab row scrolls sideways on narrow phones
      await tester.pumpAndSettle();
      await tester.tap(preOwnedTab);
      await tester.pump();
      expect(find.text('DJI Mini 4 Pro Drone'), findsNothing);
      expect(find.textContaining('DJI Air 2S'), findsOneWidget);
    });

    testWidgets('shows a sourcing option when nothing matches', (tester) async {
      await pumpSearch(tester, query: 'zzqx');
      expect(find.text('No results for "zzqx"'), findsOneWidget);
      expect(find.text('Request Sourcing'), findsOneWidget);
    });

    testWidgets('typing a query and submitting saves it as a recent search', (tester) async {
      await pumpSearch(tester);
      await tester.enterText(find.byType(TextField), 'macbook');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(find.text('Products (0)'), findsOneWidget);
      expect(find.text('Pre-Owned (1)'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('svc_recent_searches'), ['macbook']);
    });
  });
}
