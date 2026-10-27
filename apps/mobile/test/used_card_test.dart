import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/data/used_products_data.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';
import 'package:sharma_video_care_mobile/widgets/used_product_cards.dart';

import 'fixtures/used_products_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('prices use Nepali digit grouping', () {
    expect(formatUsedPrice(115000), 'Rs. 1,15,000');
    expect(formatUsedPrice(8500), 'Rs. 8,500');
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('grid tiles fit without overflow at text scale $scale', (tester) async {
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final appState = AppState();
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: const Size(393, 852), textScaler: TextScaler.linear(scale)),
          child: Builder(
            builder: (context) => Scaffold(
              body: CustomScrollView(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: UsedProductCard.extentFor((393 - 28 - 12) / 2, TextScaler.linear(scale)),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => UsedProductCard(item: kSampleUsedProducts[i], appState: appState),
                      childCount: kSampleUsedProducts.length,
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
      expect(find.textContaining(RegExp(r'^Rs\. \d{1,3}(,\d{2})*,\d{3}$')), findsWidgets);
      expect(find.textContaining(RegExp(r'Rs\. \d+k')), findsNothing);
    });
  }
}
