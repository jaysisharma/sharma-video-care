import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/models/models.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';
import 'package:sharma_video_care_mobile/widgets/store_product_widgets.dart';

ProductModel _product(String id, Map<String, dynamic> data) => ProductModel.fromFirestore(id, {
      'name': 'Canon RF 70-200mm f/2.8L IS USM Telephoto Zoom Lens',
      'brand': 'Canon',
      'categoryName': 'Lenses',
      'price': 485000,
      ...data,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('productMatchesCategory', () {
    test('short keywords match whole words only', () {
      final ac = _product('ac', {'categoryName': 'AC & Cooling'});
      final accessories = _product('acc', {'categoryName': 'Accessories'});
      expect(productMatchesCategory(ac, 'AC'), isTrue);
      expect(productMatchesCategory(accessories, 'AC'), isFalse);
      expect(productMatchesCategory(accessories, 'Accessories'), isTrue);
    });

    test('plural and singular category names both match', () {
      expect(productMatchesCategory(_product('a', {'categoryName': 'Camera'}), 'Cameras'), isTrue);
      expect(productMatchesCategory(_product('b', {'categoryName': 'Cinema Cameras'}), 'Cameras'), isTrue);
      expect(productMatchesCategory(_product('c', {'categoryName': 'Lens'}), 'Lenses'), isTrue);
      expect(productMatchesCategory(_product('d', {'categoryName': 'Drones'}), 'Lenses'), isFalse);
      expect(productMatchesCategory(_product('e', {'categoryName': 'Anything'}), 'All'), isTrue);
    });
  });

  group('productStockLabel', () {
    test('reflects real availability only', () {
      expect(productStockLabel(_product('a', {'availabilityType': 'OUT_OF_STOCK'}), false)?.text, 'Out of stock');
      expect(productStockLabel(_product('b', {'availabilityType': 'SOURCE_ON_REQUEST'}), false)?.text, 'On request');
      expect(productStockLabel(_product('c', {'stockQuantity': 2}), false)?.text, 'Only 2 left');
      expect(productStockLabel(_product('d', {'stockQuantity': 40}), false), isNull);
      expect(productStockLabel(_product('e', {}), false), isNull); // unset stock isn't "0 left"
    });
  });

  for (final width in [320.0, 393.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('store cards fit at ${width}dp width, text scale $scale', (tester) async {
        tester.view.physicalSize = Size(width * 3, 2556);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        final appState = AppState();
        final products = [
          _product('sale', {'originalPrice': 540000, 'stockQuantity': 2}),
          _product('plain', {'name': 'Short name', 'stockQuantity': 10}),
          _product('sold', {'availabilityType': 'OUT_OF_STOCK'}),
          _product('request', {'availabilityType': 'SOURCE_ON_REQUEST', 'originalPrice': 600000}),
        ];
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(width, 852), textScaler: TextScaler.linear(scale)),
            child: Builder(
              builder: (context) => Scaffold(
                body: CustomScrollView(slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: SliverGrid(
                      gridDelegate: StoreProductCard.gridDelegate(context),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => StoreProductCard(product: products[i], appState: appState),
                        childCount: products.length,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('-10%'), findsOneWidget); // 540000 -> 485000
        expect(find.text('Out of stock'), findsOneWidget); // badge on the photo
        expect(find.text('Sold out'), findsNothing);
        expect(find.byIcon(Icons.add), findsNWidgets(3)); // no cart button on the sold-out card
        expect(find.textContaining('★'), findsNothing);
      });
    }
  }
}
